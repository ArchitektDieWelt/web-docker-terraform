console.log('Loading function');

const aws = require('aws-sdk');
const Ajv = require("ajv")
const fs = require("fs")
const YAML = require("yaml")

const s3 = new aws.S3({ apiVersion: '2006-03-01' });
const cloudfront = new aws.CloudFront();
const schemaFiles = [
  './schemas/ObservedConfig.yaml',
  './schemas/PageConfig.yaml'
];

function buildValidator() {
  const schemas = schemaFiles.map(file => YAML.parse(fs.readFileSync(file, 'utf-8')));
  const ajv = new Ajv({schemas})
  const schema = {
    if: {
      type: "object",
      properties: {
        type: {
          const: "page"
        }
      },
      required: [
        "type"
      ]
    },
    then: {
      $ref: "pageSchema"
    },
    else: {
      $ref: "observedSchema"
    }
  }
  return ajv.compile(schema);
}

function makeid(length) {
  let result           = '';
  const characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const charactersLength = characters.length;
  for ( let i = 0; i < length; i++ ) {
    result += characters.charAt(Math.floor(Math.random() *
      charactersLength));
  }
  return result;
}

const {
  DESTINATION_BUCKET_NAME,
  DESTINATION_CONFIGS_ASSET_KEY,
  CLOUDFRONT_DISTRIBUTION_ID,
  CLOUDFRONT_INVALIDATION_PATH } = process.env;

exports.handler = async (event, context) => {
  const bucket = event.Records[0].s3.bucket.name;

  const params = {
    Bucket: bucket,
  };

  const validate = buildValidator();

  const { Contents }  = await s3.listObjectsV2(params).promise();

  const fileConfigs = await Promise.all(Contents.map(async (config, index) => {
    const file = await s3.getObject({ Bucket: bucket, Key: config.Key }).promise();
    let configFile;
    try {
      configFile = JSON.parse(file.Body.toString())
    } catch (e) {
      throw new Error('Config: ' + config.Key + ' is not a valid JSON');
    }

    if(!validate(configFile)) {
      throw new Error('Config: ' + config.Key + ' is invalid\nSchema:' + JSON.stringify(validate.errors, null, 2))
    }
    return file.Body.toString();
  }));

  const allConfigs = fileConfigs.reduce((prev, next, index) => {
    if (index !== fileConfigs.length - 1)
      return prev.concat(next).concat(',\n');
    return prev.concat(next);
  }, '[\n').concat(']\n');

  try {
    JSON.parse(allConfigs)
  } catch (e) {
    throw new Error('Could not parse JSON');
  }

  console.log('All configs:', allConfigs);

  await s3.putObject({
    Bucket: DESTINATION_BUCKET_NAME,
    Key: DESTINATION_CONFIGS_ASSET_KEY,
    Body: allConfigs,
    ContentType: 'text'
  }).promise();

  console.log('uploaded configs to:', DESTINATION_CONFIGS_ASSET_KEY);

  const reference = makeid(16);
  const couldFrontParams = {
    DistributionId: CLOUDFRONT_DISTRIBUTION_ID,
    InvalidationBatch: {
      CallerReference: reference,
      Paths: {
        Quantity: 1,
        Items: [
          CLOUDFRONT_INVALIDATION_PATH,
        ]
      }
    }
  };
  await cloudfront.createInvalidation(couldFrontParams).promise();
};

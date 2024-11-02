const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    const bucketName = process.env.BUCKET_NAME;
    const basePrefix = process.env.PATH_PREFIX;
    
    try {
        // Get current date for path partitioning
        const now = new Date();
        const year = now.getUTCFullYear();
        const month = String(now.getUTCMonth() + 1).padStart(2, '0');
        const day = String(now.getUTCDate()).padStart(2, '0');
        const hour = String(now.getUTCHours()).padStart(2, '0');
        const timestamp = now.toISOString();
        
        // Create S3 key with partitioning
        const key = `${basePrefix}/year=${year}/month=${month}/day=${day}/hour=${hour}/${timestamp}-${event.id}.json`;
        
        // Add metadata to help with querying
        const metadata = {
            eventType: event.detail?.eventType || 'unknown',
            timestamp: timestamp,
            source: event.source || 'unknown'
        };
        
        // Upload to S3
        await s3.putObject({
            Bucket: bucketName,
            Key: key,
            Body: JSON.stringify(event),
            ContentType: 'application/json',
            Metadata: metadata
        }).promise();
        
        console.log(`Successfully stored event at s3://${bucketName}/${key}`);
        
        return {
            statusCode: 200,
            body: `Event stored at s3://${bucketName}/${key}`
        };
    } catch (error) {
        console.error('Error processing event:', error);
        throw error;
    }
};
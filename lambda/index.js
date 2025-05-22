const AWS = require('aws-sdk');
const ses = new AWS.SES({ region: 'us-east-1' });
const dynamoDB = new AWS.DynamoDB.DocumentClient();
const pinpoint = new AWS.Pinpoint({ region: 'us-east-1' });

// Environment variables set by Terraform
const pinpointProjectId = process.env.PINPOINT_PROJECT_ID;
const tableName = process.env.TABLE_NAME;
const notificationEmail = process.env.NOTIFICATION_EMAIL;
const senderEmail = process.env.SENDER_EMAIL;
const confirmationSender = process.env.CONFIRMATION_SENDER;

exports.handler = async (event) => {
  try {
    // Parse the incoming request
    const body = JSON.parse(event.body);
    const { email, name, restaurantName, message, source } = body;
    
    // Store in DynamoDB
    await dynamoDB.put({
      TableName: tableName,
      Item: {
        email,
        name,
        restaurantName,
        message: message || "Interested in a demo",
        source: source || 'marketing_page',
        timestamp: new Date().toISOString()
      }
    }).promise();
    
    // Add to Pinpoint as a contact
    await pinpoint.updateEndpoint({
      ApplicationId: pinpointProjectId,
      EndpointId: email.replace('@', 'at').replace(/\./g, 'dot'),
      EndpointRequest: {
        ChannelType: 'EMAIL',
        Address: email,
        Attributes: {
          name: [name || ''],
          restaurantName: [restaurantName || ''],
        },
        User: {
          UserAttributes: {
            name: [name || ''],
            restaurantName: [restaurantName || '']
          }
        }
      }
    }).promise();
    
    // Send confirmation email using SES
    await ses.sendEmail({
      Source: confirmationSender,
      Destination: { ToAddresses: [email] },
      Message: {
        Subject: { Data: 'Thanks for your interest in Buzser!' },
        Body: {
          Html: {
            Data: `
              <html>
                <body>
                  <h1>Hello ${name || 'there'}!</h1>
                  <p>Thank you for your interest in Buzser.</p>
                  <p>We've received your request for a demo and will be in touch shortly.</p>
                  <p>In the meantime, feel free to reply to this email with any questions.</p>
                  <p>Best regards,<br>The Buzser Team</p>
                </body>
              </html>
            `
          }
        }
      }
    }).promise();
    
    // Send notification to yourself
    await ses.sendEmail({
      Source: senderEmail,
      Destination: { ToAddresses: [notificationEmail] },
      Message: {
        Subject: { Data: 'New Demo Request from Buzser Website' },
        Body: {
          Html: {
            Data: `
              <html>
                <body>
                  <h1>New Demo Request</h1>
                  <p><strong>Name:</strong> ${name || 'Not provided'}</p>
                  <p><strong>Email:</strong> ${email}</p>
                  <p><strong>Restaurant:</strong> ${restaurantName || 'Not provided'}</p>
                  <p><strong>Message:</strong> ${message || 'Interested in a demo'}</p>
                  <p><strong>Source:</strong> ${source || 'Marketing page'}</p>
                </body>
              </html>
            `
          }
        }
      }
    }).promise();

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ message: 'Demo request received successfully!' })
    };
  } catch (error) {
    console.error('Error processing demo request:', error);
    
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ message: 'Error processing your request' })
    };
  }
};
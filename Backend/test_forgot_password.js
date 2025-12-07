const axios = require('axios');

async function testForgotPassword() {
  try {
    console.log('🧪 Testing Forgot Password Endpoint...\n');
    
    const response = await axios.post('http://localhost:3001/api/auth/forgot-password', {
      email: 'john.smith@example.com'
    });
    
    console.log('✅ Success!');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    console.log('\n📧 Check the email: john.smith@example.com');
    console.log('   (or check your Gmail sent folder: amarabdelaziz00@gmail.com)');
    
  } catch (error) {
    if (error.response) {
      console.log('❌ Error Response:');
      console.log('Status:', error.response.status);
      console.log('Data:', JSON.stringify(error.response.data, null, 2));
    } else if (error.request) {
      console.log('❌ No response from server. Is the server running?');
      console.log('   Run: npm start');
    } else {
      console.log('❌ Error:', error.message);
    }
  }
}

testForgotPassword();

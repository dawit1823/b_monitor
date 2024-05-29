// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

// class EmailService {
//   final String _sendGridApiKey = dotenv.env['SENDGRID_API_KEY']!;
//   final String _fromEmail = dotenv.env['FROM_EMAIL']!;

//   Future<void> sendWarningEmail(String userEmail, DateTime dueDate) async {
//     final daysLeft = dueDate.difference(DateTime.now()).inDays;
//     if (daysLeft == 3) {
//       final url = 'https://api.sendgrid.com/v3/mail/send';
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $_sendGridApiKey',
//           'Content-Type': 'application/json',
//         },
//         body: '''{
//           "personalizations": [{"to": [{"email": "$userEmail"}]}],
//           "from": {"email": "$_fromEmail"},
//           "subject": "Rent Due Date Warning",
//           "content": [{
//             "type": "text/plain",
//             "value": "This is a reminder that your rent is due in 3 days."
//           }]
//         }''',
//       );

//       if (response.statusCode == 202) {
//         print('Email sent successfully.');
//       } else {
//         print('Failed to send email: ${response.body}');
//       }
//     }
//   }
// }

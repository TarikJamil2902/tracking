import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracking App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.grey, // Adjust to your color scheme
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Picture
              Center(
                child: CircleAvatar(
                  radius: 60.0,
                  backgroundImage: AssetImage(
                    'assets/images/profile_pic.jpg',
                  ), // Replace with actual image
                ),
              ),
              SizedBox(height: 16),

              // User Name
              Center(
                child: Text(
                  'Tarik Jamil', // Replace with dynamic name
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),

              // User Bio or Additional Info
              Center(
                child: Text(
                  'Donor since 2017, A+ Blood Type', // Bio info
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              SizedBox(height: 16),

              // Divider
              Divider(),

              // Contact Info Section
              Text(
                'Contact Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildInfoRow('Email', 'tj@example.com'),
              _buildInfoRow('Phone', '+880123456789'),
              SizedBox(height: 16),

              // Blood Donation Stats Section
              Text(
                'Blood Donation Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildInfoRow('Total Donations', '5'),
              _buildInfoRow('Next Donation', '12 March 2025'),
              SizedBox(height: 16),

              // Social Media Section (Optional)
              Text(
                'Social Media',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildSocialMediaRow('Facebook', 'fb.com/tj'),
              _buildSocialMediaRow('Twitter', '@tj'),
              SizedBox(height: 16),

              // Action Buttons (Edit, Log Out, etc.)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Edit profile action
                  },
                  child: Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      45,
                      90,
                      146,
                    ), // Customize the button color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build information rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Helper function for social media rows
  Widget _buildSocialMediaRow(String platform, String link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            platform,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(link, style: TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }
}

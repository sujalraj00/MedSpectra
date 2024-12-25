// lib/main.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MedicalReportAnalyzer());
}

class MedicalReportAnalyzer extends StatelessWidget {
  const MedicalReportAnalyzer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Report Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedFile;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Future<void> _analyzeReport() async {
    if (_selectedFile == null) {
      _showError('Please select a file first');
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // TODO: Implement actual API call to your AI service
      // This is a mock response for demonstration
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _analysisResult = {
          'summary': 'Mock analysis of medical report',
          'keyPoints': [
            'Blood pressure: 120/80 mmHg (Normal)',
            'Cholesterol levels slightly elevated',
            'Blood sugar levels normal'
          ],
          'potentialIssues': [
            'Mild hypertension risk',
            'Consider lifestyle changes for cholesterol management'
          ],
          'recommendations': [
            'Regular exercise recommended',
            'Follow-up in 6 months',
            'Consider dietary modifications'
          ]
        };
      });
    } catch (e) {
      _showError('Error analyzing report: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Report Analyzer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Medical Report'),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              Text('Selected file: ${_selectedFile!.path.split('/').last}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeReport,
                child: _isAnalyzing
                    ? const CircularProgressIndicator()
                    : const Text('Analyze Report'),
              ),
            ],
            if (_analysisResult != null) ...[
              const SizedBox(height: 24),
              _buildAnalysisResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection('Summary', _analysisResult!['summary']),
            _buildSection('Key Points', _analysisResult!['keyPoints']),
            _buildSection(
                'Potential Issues', _analysisResult!['potentialIssues']),
            _buildSection(
                'Recommendations', _analysisResult!['recommendations']),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, dynamic content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (content is String)
          Text(content)
        else if (content is List)
          ...content.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              )),
        const SizedBox(height: 16),
      ],
    );
  }
}

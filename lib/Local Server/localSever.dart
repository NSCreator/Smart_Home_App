import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:smart_home/auth/create_account.dart';
import 'package:smart_home/functions.dart';


class FileManagementScreen extends StatefulWidget {
  @override
  _FileManagementScreenState createState() => _FileManagementScreenState();
}

class _FileManagementScreenState extends State<FileManagementScreen> {
  File? _selectedFile;
  List<Map<String, dynamic>> _files = [];
  String _currentPath = '';
  bool _isUploading = false;

  final String serverUrl = 'http://192.168.0.242:3000';

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  Future<void> _pickFile() async {
    setState(() {
      _isUploading = true;
    });

    final result = await FilePicker.platform.pickFiles();

    setState(() {
      _isUploading = false;
    });

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    setState(() {
      _isUploading = true;
    });

    if (_selectedFile == null) return;

    int totalBytes = _selectedFile!.lengthSync();
    int bytesSent = 0;

    var request = http.MultipartRequest('POST', Uri.parse('$serverUrl/upload'));

    request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
    request.fields['folder'] = _currentPath; // Specify the folder here if needed
    var streamedResponse = await request.send();

    streamedResponse.stream.listen(
          (List<int> chunk) {
        bytesSent += chunk.length;
        double progress = bytesSent / totalBytes;

        print('Upload progress: ${progress.toStringAsFixed(2)}');
        setState(() {});
      },
      onDone: () {
        _listFiles();
        setState(() {
          _isUploading = false;
        });
      },
      onError: (error) {
        // Handle error
        print('Error uploading file: $error');
        setState(() {
          _isUploading = false;
        });
      },
      cancelOnError: true,
    );
  }

  Future<void> _createFolderDialog(BuildContext context) async {
    TextEditingController _folderNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Folder'),
          content: TextField(
            controller: _folderNameController,
            decoration: InputDecoration(labelText: 'Folder Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String folderName = _folderNameController.text.trim();
                if (folderName.isNotEmpty) {
                  _createFolder(folderName);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createFolder(String folderName) async {
    var response = await http.post(
      Uri.parse('$serverUrl/create-folder'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'folder': _currentPath.isEmpty ? folderName : '$_currentPath/$folderName',
      }),
    );

    if (response.statusCode == 200) {
      print('Folder created successfully');
      _listFiles();
    } else {
      print('Failed to create folder');
    }
  }

  Future<void> _delete(String path) async {
    var response = await http.delete(
      Uri.parse('$serverUrl/delete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'path': path,
      }),
    );

    if (response.statusCode == 200) {
      print('Deleted successfully');
      _listFiles();
    } else {
      print('Failed to delete');
    }
  }

  Future<void> _listFiles() async {
    var response = await http.get(Uri.parse('$serverUrl/files?path=$_currentPath'));

    if (response.statusCode == 200) {
      setState(() {
        _files = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to load files');
    }
  }

  void _navigateToFolder(String folderName) {
    setState(() {
      _currentPath = _currentPath.isEmpty ? folderName : '$_currentPath/$folderName';
      _listFiles();
    });
  }

  void _navigateBack() {
    setState(() {
      List<String> pathParts = _currentPath.split('/');
      pathParts.removeLast();
      _currentPath = pathParts.join('/');
      _currentPath = _currentPath.isEmpty ? '' : _currentPath;
      _listFiles();
    });
  }
  bool _isBottomSheetVisible = false;
  void _showInitialBottomSheet() {
    setState(() {
      _isBottomSheetVisible = true;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isBottomSheetVisible = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _pickFile,
                        child: Text('Select File'),
                      ),
                      ElevatedButton(
                        onPressed: _uploadFile,
                        child: Text('Upload File'),
                      ),
                      ElevatedButton(
                        onPressed: () => _createFolderDialog(context),
                        child: Text('Create Folder'),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _isBottomSheetVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            backButton(),
            HeadingH1(heading: "File Storage System"),
            _isUploading ? LinearProgressIndicator() : Container(),
            Center(
              child: _selectedFile == null
                  ? Text('No file selected.',style: TextStyle(color: Colors.white),)
                  : Text('Selected file: ${_selectedFile!.path}',style: TextStyle(color: Colors.white),),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return ListTile(
                    leading: Icon(file['isDirectory'] ? Icons.folder : Icons.insert_drive_file,color:file['isDirectory'] ?Colors.white: Colors.blue,),
                    title: Text(file['name'],style: TextStyle(color: Colors.white),),
                    trailing: IconButton(
                      icon: Icon(Icons.delete,color: Colors.orangeAccent,),
                      onPressed: () => _delete('$_currentPath/${file['name']}'),
                    ),
                    onTap: file['isDirectory']
                        ? () => _navigateToFolder(file['name'])
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showInitialBottomSheet();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

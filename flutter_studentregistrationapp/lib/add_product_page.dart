import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddusersPage extends StatefulWidget {
  const AddusersPage({super.key});

  @override
  State<AddusersPage> createState() => _AddusersPageState();
}

class _AddusersPageState extends State<AddusersPage> {

  ////////////////////////////////////////////////////////////
  // ✅ Controllers
  ////////////////////////////////////////////////////////////

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  ////////////////////////////////////////////////////////////
  // ✅ Image (ใช้ XFile รองรับ Web)
  ////////////////////////////////////////////////////////////

  XFile? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ Save users + Upload Image
  ////////////////////////////////////////////////////////////

  Future<void> saveusers() async {

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกรูปภาพ")),
      );
      return;
    }

    final url = Uri.parse(
      "http://localhost/flutter_studentregistrationapp/php_api/insert_product.php",
    );

    var request = http.MultipartRequest('POST', url);

    ////////////////////////////////////////////////////////////
    // ✅ Fields
    ////////////////////////////////////////////////////////////

    request.fields['name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['phone'] = phoneController.text;

    ////////////////////////////////////////////////////////////
    // ✅ Upload Image (แยก Web / Mobile)
    ////////////////////////////////////////////////////////////

    if (kIsWeb) {

      final bytes = await selectedImage!.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: selectedImage!.name,
        ),
      );

    } else {

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          selectedImage!.path,
        ),
      );
    }

    ////////////////////////////////////////////////////////////
    // ✅ Execute
    ////////////////////////////////////////////////////////////

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    final data = json.decode(responseData);

    if (data["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เพิ่มชื่อนักเรียนเรียบร้อย")),
      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${data["error"]}")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เพิ่มรายชื่อนักเรียน")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            children: [

              ////////////////////////////////////////////////////////////
              // 🖼 Image Preview (สำคัญมาก)
              ////////////////////////////////////////////////////////////

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: selectedImage == null
                      ? const Center(
                          child: Text("แตะเพื่อเลือกรูป"),
                        )
                      : kIsWeb
                          ? Image.network(
                              selectedImage!.path, // ✅ Web
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImage!.path), // ✅ Mobile
                              fit: BoxFit.cover,
                            ),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 🏷 Name
              ////////////////////////////////////////////////////////////

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อนักเรียน",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 💰 emsil
              ////////////////////////////////////////////////////////////

              TextField(
                controller: emailController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "อีเมล",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 📝 phone
              ////////////////////////////////////////////////////////////

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "เบอร์โทร",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ////////////////////////////////////////////////////////////
              // ✅ Button
              ////////////////////////////////////////////////////////////

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveusers,
                  child: const Text("บันทึกรายชื่อ"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

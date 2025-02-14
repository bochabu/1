import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Cập nhật cấu trúc dữ liệu sản phẩm
  List<Product> products = [
    Product(name: "Bút", quantity: 9, price: 15000, ma: 'LK_04697', time: DateTime.utc(2024, 2, 25)),
    Product(name: "Vở", quantity: 20, price: 15000, ma: 'LK_04666', time: DateTime.utc(2024, 2, 29)),
    Product(name: "Chai Nước", quantity: 5, price: 10000, ma: '8934588063053', time: DateTime.utc(2024, 3, 3)),
    // Thêm các sản phẩm khác theo cùng cấu trúc này
  ];
  bool isNhapsPressed = false;
  bool isXuatsPressed = false;
  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);

      if (!mounted) return;
  int temp = 0;
      for (var product in products) {
        if (product.ma == qrCode) {
          temp = 1;
          if (isNhapsPressed) {
            product.quantity += 1;
            product.time = DateTime.now();
          }
          if (isXuatsPressed) {
            product.quantity -= 1;
            product.time = DateTime.now();
          }
        }
      }

      if (qrCode == 'LK_04697') {
        setState(() {
          // Tìm sản phẩm trong danh sách và tăng số lượng lên 1
          int index = products.indexWhere((product) => product.name == "Bút");
          if (index != -1) {
            // Tăng số lượng sản phẩm lên 1
            if (isNhapsPressed) {
              products[0].quantity += 0;
              products[0].time = DateTime.now();
              
            }
            if (isXuatsPressed) {
              products[0].quantity -= 0;
              products[0].time = DateTime.now();
            }
          } else {
            // Nếu không tìm thấy sản phẩm, có thể thêm mới hoặc bỏ qua
            products.add(
                Product(name: "Bút", quantity: 1, price: 5000, ma: 'LK_04697', time: DateTime.utc(2024, 3, 3)));
          }
        });
      } else if (qrCode == '8934588063053') {
        setState(() {
          // Tìm sản phẩm bút trong danh sách và tăng số lượng lên 1
          int index =
              products.indexWhere((product) => product.name == "Chai Nước");
          if (index != -1) {
            // Tăng số lượng sản phẩm bút lên 1
            products[1].quantity += 0;
          } else {
            // Nếu không tìm thấy sản phẩm bút, có thể thêm mới hoặc bỏ qua
            products.add(Product(
                name: "Bút", quantity: 1, price: 5000, ma: '8934588063053', time: DateTime.utc(2024, 3, 3)));
          }
        });
      }else{
        if(temp == 0){
          _showAddProductDialog(qrCode);
        }
         setState(() {});
      }
    } catch (e) {
    }
  }

  void _showAddProductDialog(String qrCode) {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thêm Sản Phẩm Mới"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Tên Sản Phẩm"),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Giá Tiền"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Thêm"),
              onPressed: () {
                setState(() {
                  products.add(Product(
                      name: nameController.text,
                      quantity: 1,
                      price: int.tryParse(priceController.text) ?? 0,
                      ma: qrCode,
                      time: DateTime.now()));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  String _formattedDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 206, 236),
      appBar: AppBar(
        title: Text('Mai Đông Thức - Mã Quang Lộc'),
        backgroundColor: Color.fromARGB(173, 216, 230, 0),
      ),
      body: Container(
        margin: EdgeInsets.all(10), 
        padding: EdgeInsets.all(10), 
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 184, 175, 175),
          borderRadius: BorderRadius.circular(10), 
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), 
              spreadRadius: 5, 
              blurRadius: 7, 
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Color.fromARGB(255, 232, 162, 96)), 
            dataRowColor: MaterialStateProperty.all(Color.fromARGB(255, 166, 227, 255),),
            columns: [
              DataColumn(label: Text('Tên')),
              DataColumn(label: Text('SL')),
              DataColumn(label: Text('Giá Thành')),
              DataColumn(label: Text('Mã Sản Phẩm')),
              DataColumn(label: Text('Thời Gian')),
            ],
            rows: products
                .map((product) => DataRow(cells: [
                      DataCell(Text(product.name)),
                      DataCell(Text('${product.quantity}')),
                      DataCell(Text('${product.price} VND')),
                      DataCell(Text('${product.ma}')),
                      DataCell(Text('${_formattedDateTime(product.time)}')),
                    ]))
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => scanQRCode(),
        child: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: const Color.fromARGB(250, 216, 230, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.download,
                  color: isNhapsPressed ? Colors.red : Colors.blue),
              onPressed: () {
                setState(() {
                  isNhapsPressed = true;
                  isXuatsPressed = false;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.upload,
                  color: isXuatsPressed ? Colors.red : Colors.blue),
              onPressed: () {
                setState(() {
                  isXuatsPressed = true;
                  isNhapsPressed = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  int quantity;
  final int price;
  String ma;
  DateTime time;

  Product(
      {required this.name,
      required this.quantity,
      required this.price,
      required this.ma,
      required this.time});
}
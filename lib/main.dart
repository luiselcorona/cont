import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Contador de Billetes',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: BillCounterScreen(),
    );
  }
}

class BillCounterController extends GetxController {
  final List<int> denominations = [1000, 500, 200, 100, 50, 20, 10, 5, 3, 1].obs;
  final RxList<TextEditingController> controllers = <TextEditingController>[].obs;
  final TextEditingController newDenominationController = TextEditingController();
  var isDarkMode = false.obs;
  var total = 0.obs;

  @override
  void onInit() {
    super.onInit();
    for (var _ in denominations) {
      final controller = TextEditingController();
      controller.addListener(calculateTotal);
      controllers.add(controller);
    }
    ever(controllers, (_) => calculateTotal());
  }

  void calculateTotal() {
    int newTotal = 0;
    for (int i = 0; i < denominations.length; i++) {
      int? quantity = int.tryParse(controllers[i].text);
      newTotal += (quantity ?? 0) * denominations[i];
    }
    total.value = newTotal;
  }

  void resetFields() {
    for (var controller in controllers) {
      controller.clear();
    }
    newDenominationController.clear();
    update();
  }

  void addDenomination() {
    int? newDenomination = int.tryParse(newDenominationController.text);
    if (newDenomination != null && newDenomination > 0) {
      denominations.add(newDenomination);
      denominations.sort((a, b) => b.compareTo(a));
      int index = denominations.indexOf(newDenomination);
      controllers.insert(index, TextEditingController()..addListener(calculateTotal));
      newDenominationController.clear();
    } else {
      Get.snackbar('Error', 'Por favor, ingresa una denominación válida.');
    }
  }

  void removeDenomination(int index) {
    denominations.removeAt(index);
    controllers.removeAt(index);
    update();
  }

  void confirmRemoveDenomination(int index) {
    Get.defaultDialog(
      title: 'Eliminar Cantidad',
      middleText: '¿Estás seguro de eliminar la denominación de ${denominations[index]} CUP?',
      textCancel: 'No',
      textConfirm: 'Sí',
      onConfirm: () {
        removeDenomination(index);
        Get.back();
      },
    );
  }

  @override
  void onClose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    newDenominationController.dispose();
    super.onClose();
  }
}

class BillCounterScreen extends StatelessWidget {
  const BillCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BillCounterController controller = Get.put(BillCounterController());

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Contador de Billetes'),
        
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              Get.to(() => AboutPage());
            },
            tooltip: 'About',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.resetFields,
            tooltip: 'Refrescar',
          ),
          Obx(() => Switch(
            value: controller.isDarkMode.value,
            onChanged: (value) {
              controller.isDarkMode.value = value;
            },
          )),
        ],
      ),
      body: Obx(() => Container(
        color: controller.isDarkMode.value ? Colors.black : Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  'Total: ${controller.total.value} CUP',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: controller.isDarkMode.value ? Colors.white : Colors.black),
                )),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.newDenominationController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: controller.isDarkMode.value ? Colors.white : Colors.black),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nueva Cantidad',
                hintStyle: TextStyle(color: controller.isDarkMode.value ? Colors.white : Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.teal),
                  onPressed: controller.addDenomination,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: controller.denominations.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () => controller.confirmRemoveDenomination(index),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: const Color.fromARGB(255, 167, 207, 235),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${controller.denominations[index]} CUP',
                              style: TextStyle(fontSize: 18, color: controller.isDarkMode.value ? Colors.white : Colors.black),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: controller.controllers[index],
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: controller.isDarkMode.value ? Colors.white : Colors.black),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(color: controller.isDarkMode.value ? Colors.white : Colors.black),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}

// ignore: use_key_in_widget_constructors
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Contador de Billetes'),
            SizedBox(width: 10),
            Icon(Icons.monetization_on, color: Colors.white),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Información',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Contador de Billetes es una aplicación diseñada para ayudarte a llevar un registro de tus gastos y ahorros.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                    
                  ),
                  SizedBox(height: 16,),
                  Text(
                    'Versión: 1.0',
                    style: TextStyle(fontSize: 18,  color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Derechos de autor: Luis.elcorona',
                    style: TextStyle(fontSize: 18,  color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
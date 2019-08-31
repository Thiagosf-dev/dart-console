import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

main() {
  menu();
}

void menu() {
  print("\n------------------------------ MENU ------------------------------");
  print("Informe uma opção:");
  print("1 - Ver a cotação do dia");
  print("2 - Registrar a cotação do dia");
  print("3 - Visualizar cotações registradas");

  String option = stdin.readLineSync();
  choseOption(option);
}

void choseOption(String option) {
  switch (int.parse(option)) {
    case 1:
      today();
      break;

    case 2:
      registerData();
      break;

    case 3:
      listData();
      break;

    default:
      print("Opção inválida");
      menu();
      break;
  }
}

void today() async {
  var data = await getData();
  print(
      "\n------------------------------ HG Brasil - COTAÇÃO ------------------------------");
  print("${data['date']} -> ${data['data']}\n\n");
}

registerData() async {
  var data = await getData();
  dynamic fileData = readFile();

  fileData = (fileData != null && fileData.length > 0
      ? json.decode(fileData)
      : List());

  if (!existsNow(fileData)) {
    createFile(fileData, data);
  } else {
    print("\nJá existe um arquivo com o registro de LOG para a data de hoje!");
  }
}

Future getData() async {
  String url = "https://api.hgbrasil.com/finance?key=b8550457";
  http.Response response = await http.get(url);

  if (response.statusCode == 200) {
    var data = json.decode(response.body)['results']['currencies'];
    var usd = data['USD'];

    Map formatedMap = Map();
    formatedMap['date'] = now();
    formatedMap['data'] = '${usd['name']}: ${usd['buy']}';

    return formatedMap;
  } else {
    throw ('Erro ao tentar realizar a operação!');
  }
}

String now() {
  var now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString()}';
}

bool existsNow(List fileData) {
  bool exists = false;

  fileData.forEach((f) {
    if (f['date'] == now()) {
      exists = true;
    }
  });

  return exists;
}

String readFile() {
  Directory path = Directory.current;
  File file = File(path.path + "/data_file.txt");

  return file.readAsStringSync();
}

void createFile(dynamic fileData, var data) {
  fileData.add({"date": now(), "data": "${data['data']}"});

  Directory path = Directory.current;
  File file = File(path.path + "/data_file.txt");
  RandomAccessFile raf = file.openSync(mode: FileMode.write);
  raf.writeStringSync(json.encode(fileData).toString());
  raf.flushSync();
  raf.closeSync();

  print("Registro salvo com sucesso");
}

void listData() {
  dynamic fileData = readFile();

  fileData = (fileData != null && fileData.length > 0
      ? json.decode(fileData)
      : List());

  print("\n########## Listagem de Cotações Registradas ##########");

  if (fileData.length > 0) {
    fileData.forEach((data) {
      print('${data['date']} <-> ${data['data']}\n');
    });
  } else {
    print("\nNão existem cotações registradas!\n");
  }
}

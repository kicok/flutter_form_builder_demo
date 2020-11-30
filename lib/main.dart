import 'package:flutter/material.dart';
import 'package:flutter_form_build_demo/data.dart';
import 'package:flutter_form_build_demo/result.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormBuilderState> _fbkey = GlobalKey<FormBuilderState>();
  final DateTime startDate = DateTime.now();

  void _submit() {
    if (!_fbkey.currentState.validate()) {
      return;
    }

    _fbkey.currentState.save();

    final inputValue = _fbkey.currentState.value;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Result(values: inputValue);
        },
      ),
    );

    print('inputValue...');
    print(inputValue);
  }

  List<String> getSuggestion(String pattern) {
    if (pattern.isEmpty) {
      return [];
    }

    List<String> matchs = [];
    final regionNames = regions.map((region) => region['regionName']).toList();

    matchs.addAll(regionNames);

    matchs.retainWhere((s) => s.contains(pattern));

    return matchs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Builder Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 20,
            ),
            child: FormBuilder(
              key: _fbkey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  FormBuilderDateTimePicker(
                    name: 'startDate',
                    inputType: InputType.date,
                    initialDate: startDate,
                    firstDate: startDate,
                    lastDate: DateTime(
                        startDate.year + 1, startDate.month, startDate.day),
                    format: DateFormat('yyyy-MM-dd '),
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '시작일',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(context,
                        errorText: '시작일은 필수입니다.'),
                  ),
                  SizedBox(height: 20),
                  FormBuilderDateTimePicker(
                    name: 'endDate',
                    inputType: InputType.date,
                    initialDate: startDate,
                    firstDate: startDate,
                    lastDate: DateTime(
                        startDate.year + 1, startDate.month, startDate.day),
                    format: DateFormat('yyyy-MM-dd '),
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '종료일',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: '종료일은 필수입니다.'),
                      (val) {
                        final sd =
                            _fbkey.currentState.fields['startDate'].value;

                        if (sd != null && val.isBefore(sd)) {
                          return '종료일이 시작일보다 앞 입니다';
                        }
                        return null;
                      }
                    ]),
                  ),
                  SizedBox(height: 20),
                  FormBuilderDropdown(
                    name: 'cropId',
                    hint: Text('대상 품종을 선택하세요'),
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(context,
                        errorText: '품종은 필수 선택입니다.'),
                    items: crops.map<DropdownMenuItem<String>>((crop) {
                      return DropdownMenuItem(
                        child: Text(crop['cropName']),
                        value: crop['id'],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  FormBuilderTypeAhead(
                    name: 'region',
                    initialValue: '서울',
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '시군구',
                      hintText: '시순구를 입력하면 자동완성됩니다.',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      print(val);
                    },
                    validator: FormBuilderValidators.compose([
                      (val) {
                        // final sd = _fbkey.currentState.fields['region'].value;
                        // print(sd);
                      },
                      FormBuilderValidators.required(
                        context,
                        errorText: '시군구s는 필수 입력사항입니다.',
                      ),
                    ]),
                    itemBuilder: (context, suggestion) {
                      return ListTile(title: Text(suggestion));
                    },
                    suggestionsCallback: (pattern) {
                      return getSuggestion(pattern);
                    },
                  ),
                  SizedBox(height: 20),
                  FormBuilderTextField(
                    name: 'area',
                    decoration: InputDecoration(
                      filled: true,
                      labelText: '면적',
                      hintText: '제곱미터 단위로 면적을 입력하세요.',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context,
                          errorText: '면적은 필수 입니다.'),
                      FormBuilderValidators.numeric(context,
                          errorText: '숫자만 입력가능합니다.'),
                      (val) {
                        final area = double.parse(val);
                        if (area < 100 || area > 10000) {
                          return '유효면적은 100에서 10,000사이 입니다.';
                        }
                        return null;
                      }
                    ]),
                  ),
                  SizedBox(height: 20),
                  FormBuilderRadioGroup(
                    name: 'urgent',
                    decoration: InputDecoration(
                      labelText: '긴급 여부',
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    options: ['긴급', '보통']
                        .map((e) => FormBuilderFieldOption(
                              value: e,
                            ))
                        .toList(),
                    validator: FormBuilderValidators.required(context,
                        errorText: '긴급여부를 선택하세요.'),
                  ),
                  SizedBox(height: 20),
                  FormBuilderCheckboxGroup(
                    name: 'warnings',
                    decoration: InputDecoration(
                      labelText: '주의사항',
                      filled: true,
                      fillColor: Colors.amberAccent,
                      border: OutlineInputBorder(),
                    ),
                    options: ['악천후시 일정 재협의', '맑으면 계획대로']
                        .map((e) => FormBuilderFieldOption(
                              value: e,
                            ))
                        .toList(),
                    validator: FormBuilderValidators.compose([
                      (val) {
                        if (val == null || val.isEmpty) {
                          return '주의 사항은 필수 입력사항입니다.';
                        }
                        if (val.length != 2) {
                          return '전부 동의하셔야 합니다.';
                        }
                        return null;
                      }
                    ]),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                child: Text('SUBMIT',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                color: Colors.indigo,
                minWidth: 120,
                onPressed: _submit,
              ),
              MaterialButton(
                child: Text('RESET',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                color: Colors.red,
                minWidth: 18,
                onPressed: () {
                  _fbkey.currentState.reset();
                },
              ),
            ],
          )
        ]),
      ),
    );
  }
}

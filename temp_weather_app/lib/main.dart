import 'package:flutter/material.dart';
import 'package:temp_weather_app/weather-card.dart';
import 'package:temp_weather_app/weather-data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
const WEATHER_API_URL = 'http://localhost:3000/api/weather/';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var title = 'Weather';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        cardColor: Colors.lightGreen[200],
        splashColor: Colors.green[700]?.withAlpha(100),
      ),
      home: Home(title: title),
    );
  }
}

class Home extends StatefulWidget {
  Home({required this.title});

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();

  WeatherData _weatherData = WeatherData('londonon');
  String? _apiError ="";

  Widget buildErrorMessage() {
    if (this._apiError != null) {
      print(this._apiError);
      return Text(
        this._apiError!,
        style: TextStyle(color: Colors.red),
      );
    }
    return Container(width: 0, height: 0);
  }

  Widget buildCityLabel() {
    return Text(
      'Select a city to view the weather',
      style: TextStyle(fontSize: 20.0),
    );
  }

  Widget buildCityFormField() {
    return DropdownButton<String>(
      value: _weatherData.location,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        color: Colors.black45,
        fontSize: 26,
      ),
      underline: Container(
        height: 2,
        color: Colors.black87,
      ),
      items: <Location>[
        new Location('London, ON', 'londonon'),
        new Location('Toronto, ON', 'torontoon'),
        new Location('New York, NY', 'newyorkny'),
        new Location('London, England', 'londonen')
      ].map<DropdownMenuItem<String>>((Location value) {
        return DropdownMenuItem<String>(
          value: value.code,
          child: Text(value.name),
        );
      }).toList(),
      onChanged: (newValue) {
        if (this._weatherData.location != newValue) {
          setState(() {
            this._weatherData.location = newValue!;
            fetchWeatherData(location: this._weatherData.location);
          });
        }
      },
    );
  }

  // Retrieve weather data from the Weather API
  fetchWeatherData({required String location}) async {
    var url = Uri.parse(WEATHER_API_URL + location);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        this._weatherData = WeatherData(
          jsonResponse['weather']['location'],
          temperature: jsonResponse['weather']['temperature'],
          weatherDescription: jsonResponse['weather']['weatherDescription'],
        );
        this._apiError = null;
      });
    } else {
      setState(() {
        this._apiError =
            'Unable to retrieve weather data from API (HTTP ${response.statusCode})';
      });
    }
  }

  @override
  initState() {
    super.initState();
    fetchWeatherData(location: this._weatherData.location);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildErrorMessage(),
              buildCityLabel(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: buildCityFormField(),
              ),
              WeatherCard(
                weatherData: _weatherData,
                onTap: () {
                  fetchWeatherData(location: this._weatherData.location);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

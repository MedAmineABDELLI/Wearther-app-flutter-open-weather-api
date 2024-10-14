import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class Weatherpage extends StatefulWidget {
  const Weatherpage({super.key});

  @override
  State<Weatherpage> createState() => _WeatherpageState();
}

class _WeatherpageState extends State<Weatherpage> {
  final WeatherFactory _wf = WeatherFactory("407322c4d87911c1ddfbcf14249e80ff");
  Weather? _weather;
  bool _loading = false;
  String? _errorMessage;
  TextEditingController _cityController = TextEditingController();  // Ajoutez un TextEditingController

  Future<void> _getWeatherData(String city) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      Weather weather = await _wf.currentWeatherByCityName(city);
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération des données météo: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _cityController,  // Associez le TextEditingController au TextField
            decoration: const InputDecoration(
              labelText: 'Entrez le nom de la ville',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String city = _cityController.text.trim();
            if (city.isNotEmpty) {
              _getWeatherData(city);  // Utilisez la ville entrée par l'utilisateur
            }
          },
          child: const Text('Rechercher'),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const CircularProgressIndicator(),
        if (_errorMessage != null)
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        if (!_loading && _weather != null) _buildWeatherInfo(),
      ],
    );
  }

  Widget _buildWeatherInfo() {
    return Column(
      children: [
        _locationHeader(),
        _dateTime(),
        _weatherIcon(),
        _current_temp(),
        _extrainfo(),
      ],
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "Lieu inconnu",
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateTime() {
    DateTime now = _weather?.date ?? DateTime.now();
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(fontSize: 35),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              " ${DateFormat("d.M.y").format(now)}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    String? iconCode = _weather?.weatherIcon;

    if (iconCode == null) {
      return const Text('Aucune icône météo disponible.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://openweathermap.org/img/wn/$iconCode@4x.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _current_temp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)} °C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 50,
      ),
    );
  }

  Widget _extrainfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).height * 0.5,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Max:${_weather?.tempMax?.celsius?.toStringAsFixed(0)}°C   ",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Min:${_weather?.tempMin?.celsius?.toStringAsFixed(0)}°C   ",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Humidité: ${_weather?.humidity?.toStringAsFixed(0)}% ",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Vent: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s ",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          )
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  //Se crean dos listas donde se almacenaran temporalmente las latitudes y longitudes, en este caso son de tipo String
  List<String> latitudS = [];
  List<String> longitudS = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  //Se crea una función que cargara en las listas lo que este guardado en el sharedPreferences, esto para anexar a la lista lo que ya estaba
  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      latitudS = prefs.getStringList('latitud') ?? [];
      longitudS = prefs.getStringList('longitud') ?? [];
    });
  }

  //Se crea una función de tipo position para determinar la posición del dispositivo
  Future<Position> detPos () async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();  //Checamos permisos

    //Comprobamos si los permisos fueron denegados
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();

      if(permission == LocationPermission.denied){
        return Future.error('error');
      }
    }

    //Si no fueron denegados se retorna la posición actual
    return await Geolocator.getCurrentPosition();
  }

  //Se crea una función para guardar en el dispositivo la latitud y longitud
  void saveLatLon() async {
    Position position = await detPos(); //Se crea una instancia de la función detPos la cual nos ayudara a recuperar la latitud y longitud
    SharedPreferences prefs = await SharedPreferences.getInstance();  //Se crea una instancia del sharedPreferences

    setState(() {
      latitudS.add(position.latitude.toString());   //Se guarda en la lista de String la latitud recuperada
      longitudS.add(position.longitude.toString()); //Se guarda en la lista de String la longitud recuperada

      //Se realiza el guardado de lo que tenemos en las listas en el sharedPreferences con sus claves correspondientes
      prefs.setStringList('latitud', latitudS);
      prefs.setStringList('longitud', longitudS);
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracking"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    fixedSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    saveLatLon(); //Invocamos la función que guardara la latitud y longitud
                  },
                  child: const Text("LOCATION NOW", style: TextStyle(color: Colors.black))
                )
              ],
            ),
            const SizedBox(height: 25),
            Column(
              children: [
                const Text("Ubicaciones", style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Latitudes", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Longitudes", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    //Aquí se muestra lo que contienen la lista de las latitudes
                    Expanded(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: 510,
                          child: ListView.builder(
                            itemCount: latitudS.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(latitudS[index]),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    //Aquí se muestra lo que contienen la lista de las longitudes
                    Expanded(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: 510,
                          child: ListView.builder(
                            itemCount: longitudS.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(longitudS[index]),
                              );
                            },
                          ),
                        ),
                      )
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
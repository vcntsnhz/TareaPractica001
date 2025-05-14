🔧 **PASOS PARA CONFIGURAR FLUTTER TRAS CLONAR EL REPOSITORIO**

1. Verificar que Flutter Web esté habilitado

> flutter doctor

> flutter config --enable-web

2. Instalar las dependencias del proyecto

> flutter pub get

3. Compilar para web y ejecutar
   
> flutter run -d chrome

🧪 **EXTRAS ÚTILES**

1. Verificar que el archivo **firebase_options.dart** esté en el proyecto (lo genera el comando "flutterfire configure").
Si no deja ejecutar ese comando, se puede ejecutar el comando:
> ./flutterfire.bat configure

Esto debido a que el archivo necesario para ejecutar "flutterfire configure" fue movido a la carpeta del proyecto para evitar errores.

2. Verificar que en index.html (en web/) existan los scripts de Firebase.


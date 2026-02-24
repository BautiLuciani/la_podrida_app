# La Podrida App

Una aplicación Flutter elegante y funcional para gestionar partidas del juego de cartas "La Podrida", permitiendo llevar un registro de puntuaciones, rankings y estadísticas de juego.

## 🎮 Características

- **Gestión de Partidas**: Crea y gestiona partidas de La Podrida fácilmente
- **Sistema de Ranking**: Visualiza el ranking actualizado de los jugadores
- **Registro de Resultados**: Guarda y revisa todos los resultados de tus partidas
- **Configuración Personalizada**: Personaliza la experiencia según tus preferencias
- **Interfaz Intuitiva**: Diseño moderno y fácil de usar

## 📋 Requisitos Previos

- Flutter 3.0 o superior
- Dart 2.17 o superior
- Android SDK 21+ (para Android)
- Xcode (para iOS)
- Git (para clonar el repositorio)

## 🚀 Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/la_podrida_app.git
   cd la_podrida_app
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── application/
│   └── providers/           # Proveedores de estado
├── core/
│   ├── router/              # Configuración de enrutamiento
│   ├── theme/               # Temas y estilos
│   └── utils/               # Utilidades generales
├── data/
│   └── services/            # Servicios de datos
├── domain/
│   ├── logic/               # Lógica de negocio
│   └── models/              # Modelos de datos
└── presentation/
    ├── home/                # Pantalla de inicio
    ├── match/               # Gestión de partidas
    ├── ranking/             # Sistema de ranking
    ├── results/             # Registro de resultados
    ├── settings/            # Configuración
    └── setup/               # Configuración inicial
```

## 🎯 Cómo Usar

1. **Al iniciar**: Completa la configuración inicial en la pantalla de Setup
2. **Nueva Partida**: Accede a la sección Match para iniciar una nueva partida
3. **Registrar Resultados**: Ingresa los puntuaciones después de cada ronda
4. **Ver Ranking**: Consulta el ranking actualizado de todos los jugadores
5. **Configuración**: Personaliza la aplicación desde la sección Settings

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework para desarrollo multiplataforma
- **Dart**: Lenguaje de programación
- **Provider**: Gestión de estado
- **Shared Preferences**: Almacenamiento local de datos

## 👨‍💻 Autor

Bautista Luciani - [@BautiLuciani](https://github.com/BautiLuciani)  
Desarrollador de Software
LinkedIn: https://www.linkedin.com/in/bautistalucianibroquen/ 



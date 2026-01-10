# Aplikacja asystenta pierwszej pomocy

## Instalacja

Aplikacja została zaimplementowana z użyciem wieloplatformowego frameworka Flutter.

W celu zapoznania się z tym narzędziem zachęcam do przejżenia jego dokumentacji: [dokumentacja fluttera](https://docs.flutter.dev/)

W celu zbudowania aplikacji wymagane jest zainstalowanie tego narzędzia w systemie. Instrukcję instalacji można znaleść na stronie [instrukcja instalacji](https://docs.flutter.dev/install). Aplikacja docelowo ma działać w systemie Android, dlatego oprócz samego SDK Fluttera trzeba również zainstalować Android Studio wraz z SDK Androida. W instrukcji instalacji Fluttera należy wykonać również kroki w sekcji instalacji Fluttera pod Android.

## Konfigurowanie połączenia z usługą asystenta

Aplikacja do działania wymaga połączenia z serwerem na którym znajduje się backend logiczny asystenta medycznego. Komunikacja odbywa się poprzez websocket.

W pliku .env znajdują się zmienne środowiskowe aplikacji. URL serwera zapisane jest w zmiennej `WS_URL`.

## Budowanie aplikacji

Przed uruchomieniem aplikacji będąc w głównym katalogu projektu należy wykonać komendę: `flutter pub get`.

## Uruchamianie aplikacji

Przed uruchomieniem do portu USB komputera należy podłączyć poprzez kabel USB telefon z systemem Android. W ustawieniach programisty w telefonie konieczne jest włączenie Debugowania USB.

Komendą `flutter devices` można sprawdzić dostępne urządzenia docelowe dla Fluttera, powinna tam być widoczna nazwa telefonu z dopiskiem "(mobile)".

Mając podłączone urządzenie możemy uruchomić aplikację komendą: `flutter -v -d nazwa_urządzenia run`

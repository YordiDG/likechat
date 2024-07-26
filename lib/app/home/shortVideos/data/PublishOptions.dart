
// Modelo para opciones de publicación
class PublishOptions {
  String description = ''; // Descripción del video
  List<String> hashtags = []; // Lista de hashtags
  List<String> mentions = []; // Lista de menciones
  String privacyOption = 'publico'; // Opción de privacidad: publico o privado
  bool allowSave = true; // Permitir descargas
  bool allowComments = true; // Permitir comentarios
  bool allowPromote = false; // Permitir promoción
  bool allowDownloads = true; // Permitir descargas
  bool allowLocationTagging = true; // Permitir etiquetado de ubicación

  PublishOptions({
    this.description = '',
    this.hashtags = const [],
    this.mentions = const [],
    this.privacyOption = 'publico',
    this.allowSave = true,
    this.allowComments = true,
    this.allowPromote = false,
    this.allowDownloads = true,
    this.allowLocationTagging = true,
  });
}
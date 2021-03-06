//
// Código de la solución unido en un único fichero.
// Para seguir todo el proceso, tener las clases separadas por ficheros,
// y poder ejecutar los tests, echar un vistazo al código en github:
// https://github.com/rchavarria/solveet-problems/tree/master/marvel-api-dart
//

import 'dart:typed_data'; // algunos tipos necesarios para calcular MD5
import 'dart:async'; // soporte para Futures
import 'dart:convert'; // soporte para JSON

// paquete de cifrado, incluye clase para calcular MD5
import 'package:cipher/cipher.dart';
import 'package:cipher/impl/server.dart';
// paquete para realizar peticiones HTTP en una aplicación de consola
import 'package:http/http.dart' as http;


/**
  * Ejecución del programa principal
  */
void main() {
    print('Recuperando comics y personajes de Marvel');

    // crea instancia de la clase principal
    String privateKey = '<escriba aqui su clave privada>';
    String publicKey = '<escriba aqui su clave pública>';
    var md5 = new Utf8String2MD5();
    var api = new MarvelApi(md5, privateKey, publicKey);

    // el primer paso es autenticarse contra Marvel
    api.authenticate().then((authenticated) {
        if (!authenticated) {
            print('Error, marvel no pudo autentificarte, ¿has usado las claves adecuadas?');
            return;
        }

        // consulta la lista de comics e imprime su título
        api.comics().then((comics) {
            print('Comics:');
            comics.forEach((c) => print('- ${c.title}'));
        });

        // consulta la lista de personajes e imprime su nombre
        api.characters().then((characters) {
            print('Personajes:');
            characters.forEach((c) => print('- ${c.name}'));
        });
    });
}

/**
  * Utility class that encapsulates the process of calculating a MD5 hash of a
  * given message
  */
class Utf8String2MD5 {

    Utf8Encoder encoder;
    Digest md5Digest;

    Utf8String2MD5() {
        initCipher();

        encoder = new Utf8Encoder();
        md5Digest = new Digest('MD5');
    }

    /**
      * Computes the MD5 has of `message`
      */
    String digest(String message) {
        List<int> utf8Data = encoder.convert(message);
        Utf8List inputData = new Uint8List.fromList(utf8Data);
        Uint8List digestValue = md5Digest.process(inputData);

        return digestValue
            .map((i) => i.toRadixString(16)) // converts to hexadecimal string
            .map((s) => s.padLeft(2, '0')) // pad strings with 0
            .join(); // join all elements in the List to build a String
    }

}

/**
  * Class to access Marvel public API v1
  */
class MarvelApi {

    static const BASE_ENDPOINT = 'http://gateway.marvel.com';
    static const API_VERSION = '/v1/public/';

    /* compute the MD5 hash in every request */
    Utf8String2MD5 md5;
    /* user private key to acces the api */
    String privateKey;
    /* user public key to acces the api */
    String publicKey;
    /* number that must change from request to request */
    int timestamp;

    MarvelApi(this.md5, this.privateKey, this.publicKey) {
        timestamp = new DateTime.now().millisecondsSinceEpoch;
    }

    /**
      * The first call to the api must be a call to authenticate the user
      * @return Future which resolves to a Boolean value stating if the
      * authentication succeeded or not
      */
    Future<Boolean> authenticate() {
        return makeApiRequest('comics')
            .then((response) {
                return response.statusCode == 200;
            });
    }

    /**
      * Retrieves a list of comics
      */
    Future<List<Comic>> comics() {
        return retrieveEntity('comics', (c) => new Comic.fromJson(c));
    }

    /**
      * Retrieve a single comic by its id
      */
    Future<Comic> comicById(int id) {
        return retrieveEntity('comics/${id}', (c) => new Comic.fromJson(c))
            .then((comicInAList) => comicInAList[0]);
    }

    /**
      * Retrieve a list of characters
      */
    Future<List<Character>> characters() {
        return retrieveEntity('characters', (c) => new Character.fromJson(c));
    }

    /**
      * Retrieve a single character by its id
      */
    Future<Character> characterById(int id) {
        return retrieveEntity('characters/${id}', (c) => new Character.fromJson(c))
            .then((characterInAList) => characterInAList[0]);
    }

    Future makeApiRequest(entity) {
        timestamp += 1;
        var authenticationToken = timestamp.toString() + privateKey + publicKey;
        var hash = md5.digest(authenticationToken);

        String query = [
            'ts=${timestamp}',
            'apikey=${publicKey}',
            'hash=${hash}'].join('&');
        String url = '${BASE_ENDPOINT}${API_VERSION}${entity}?${query}';

        return http.get(url);
    }

    Future retrieveEntity(entity, mapper) {
        return makeApiRequest(entity)
            .then((response) {
                var body = JSON.decode(response.body);
                var results = body['data']['results'];
                var entities = results
                    .map(mapper)
                    .toList();

                return entities;
            });
    }

}

/**
  * Represents a Marvel comic
  */
class Comic {
    var builder = new ImageUrlBuilder();
    String id;
    String title;
    String description;
    /* URL to an image of the comic */
    String thumbnailUrl;

    /**
      * Named constructor to make it easy to parse data from Marvel API
      */
    Comic.fromJson(Map json) {
        id = json['id'];
        title = json['title'];
        description = json['description'];
        thumbnailUrl = builder.fromMap(json['thumbnail']);
    }

}

/**
  * Represents a Marvel character
  */
class Character {
    var builder = new ImageUrlBuilder();
    String id;
    String name;
    String description;
    /* URL to an image of the character */
    String thumbnailUrl;

    /**
      * Named constructor to make it easy to parse data from Marvel API
      */
    Character.fromJson(Map json) {
        id = json['id'];
        name = json['name'];
        description = json['description'];
        thumbnailUrl = builder.fromMap(json['thumbnail']);
    }

}

/**
  * Handles Image entities
  */
class ImageUrlBuilder {

    /**
      * Builds an Image URL from a map returned by the API
      */
    String fromMap(Map thumbnail) {
        if (thumbnail == null) {
            return '';
        }

        var path = thumbnail['path'];
        var extension = thumbnail['extension'];
        return '${path}.${extension}';
    }

}

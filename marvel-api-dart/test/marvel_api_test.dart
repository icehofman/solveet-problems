import 'dart:convert';

import 'package:unittest/unittest.dart';
// package http can be used to get remote content from the server
// documentation: https://pub.dartlang.org/packages/http
import 'package:http/http.dart' as http;

import '../bin/read_key_file.dart';
import '../bin/string2md5.dart';

void main() {

    group('HTTP Requests Spike:', () {

        test('http package gets a response from a URL', () {
            String baseEndpoint = 'http://gateway.marvel.com';
            String url = '${baseEndpoint}/v1/public/comics';

            http.get(url)
                .then((response) {
                    print(response.statusCode);
                });
        });

    });

    group('API login Spike:', () {

        test('performs the first request and gets authenticated', () {
            // reading keys
            var reader = new KeyFileReader('.env');
            reader.read();

            print('Keys have been read');
            print('Private Key: ${reader.privateKey}');
            print('Public Key: ${reader.publicKey}');

            // generating hash = md5(timestamp + keys)
            var timestamp = 1;
            var digest = new Utf8String2MD5();
            var apikey = timestamp.toString() + reader.privateKey + reader.publicKey;
            var hash = digest.digest(apikey);

            print('apikey = ${apikey}');
            print('hash: ${hash}');

            // making the first api call to authenticate
            String baseEndpoint = 'http://gateway.marvel.com';
            String query = [
                'ts=${timestamp}',
                'apikey=${reader.publicKey}',
                'hash=${hash}'].join('&');
            String url = '${baseEndpoint}/v1/public/comics?${query}';
            print('URL: ${url}');
            http.get(url)
                .then((response) {
                    print('Real api call: ${response.statusCode}');

                    var result = JSON.decode(response.body);
                    var status = result['status'];
                    print('Result.status: ${status}');

                    var comics = result['data'];
                    print('How many comics: ${comics.length}');
                })
                .catchError((e) => print(e));
        });

    });

    group('Marvel API:', () {

        test('constructor accepts 3 params: md5 digester, private key and public key', () {
            var api = buildMarvelApi();
        });

    });

}

MarvelApi buildMarvelApi() {
    var reader = new KeyFileReader('.env');
    reader.read();

    var md5 = new Utf8String2MD5();

    var api = new MarvelApi(md5, reader.privateKey, reader.publicKey);
}

class MarvelApi {

    Utf8String2MD5 md5;
    String privateKey;
    String publicKey;

    MarvelApi(this.md5, this.privateKey, this.publicKey);

}

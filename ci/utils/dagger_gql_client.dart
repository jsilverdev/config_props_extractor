import 'dart:convert';
import 'dart:io';

import 'package:graphql/client.dart';

class DaggerGQLClient {
  final GraphQLClient _client = _getClient();

  Future<Object> executeQuery(String query) async {

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception!;
    }

    return getDeepestValue(result.data!);
  }
}

GraphQLClient _getClient() {
  Map<String, String> env = Platform.environment;

  final String sessionPort = env["DAGGER_SESSION_PORT"] ??
      (throw Exception(
        "Session Port Required",
      ));
  final String sessionToken = env["DAGGER_SESSION_TOKEN"] ??
      (throw Exception(
        "Session Token Required",
      ));

  final encodedSessionToken = base64.encode(utf8.encode('$sessionToken:'));

  final link = HttpLink('http://127.0.0.1:$sessionPort/query');
  final authLink = AuthLink(getToken: () => "Basic $encodedSessionToken");

  return GraphQLClient(cache: GraphQLCache(), link: authLink.concat(link));
}

Object getDeepestValue(Map<String, dynamic> map) {
  Object deepestValue = Object();
  map.forEach((key, value) {
    if (value is Map) {
      dynamic recursiveValue = getDeepestValue(value as Map<String,dynamic>);
      if (recursiveValue != null) {
        deepestValue = recursiveValue;
      }
    } else {
      deepestValue = value;
    }
  });
  return deepestValue;
}
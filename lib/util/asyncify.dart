import 'dart:async';
import 'package:flutter/foundation.dart';

/// Returns a non UI-blocking function wrapping rawFunc
Future<R> wrapFunc<R>(FutureOr<dynamic> rawFunc) {
  return compute(rawFunc, null);
}

/// Returns a non UI-blocking function wrapping rawFunc and passing one parameter to it
Future<R> wrap1ParamFunc<R, S>(Function(S) rawFunc, S arg1) {
  return compute<S, R>(rawFunc, arg1);
}

/// Returns a non UI-blocking function wrapping rawFunc and passing a list of two parameters to it
Future<R> wrap2ParamFunc<R, S, T>(
    Function(List<dynamic>) rawFunc, S arg1, T arg2) {
  return compute<List<dynamic>, R>(rawFunc, [arg1, arg2]);
}

/// Returns a non UI-blocking function wrapping rawFunc and passing a list of three parameters to it
Future<R> wrap3ParamFunc<R, S, T, U>(
    Function(List<dynamic>) rawFunc, S arg1, T arg2, U arg3) {
  return compute<List<dynamic>, R>(rawFunc, [arg1, arg2, arg3]);
}

/// Returns a non UI-blocking function wrapping rawFunc and passing a list of four parameters to it
Future<R> wrap4ParamFunc<R, S, T, U, V>(
    Function(List<dynamic>) rawFunc, S arg1, T arg2, U arg3, V arg4) {
  return compute<List<dynamic>, R>(rawFunc, [arg1, arg2, arg3, arg4]);
}

/// Returns a non UI-blocking function wrapping rawFunc and passing a list of five parameters to it
Future<R> wrap5ParamFunc<R, S, T, U, V, W>(
    Function(List<dynamic>) rawFunc, S arg1, T arg2, U arg3, V arg4, W arg5) {
  return compute<List<dynamic>, R>(rawFunc, [arg1, arg2, arg3, arg4, arg5]);
}

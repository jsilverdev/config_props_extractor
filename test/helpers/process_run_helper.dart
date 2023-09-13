import 'dart:io';

ProcessResult processResult({required stdout}) {
  return ProcessResult(pid, exitCode, stdout, stderr);
}

enum KubeConfigKind {
  configMap(name: "ConfigMap", isOpaque: false),
  secret(name: "Secret", isOpaque: true);

  final String name;
  final bool isOpaque;

  const KubeConfigKind({
    required this.name,
    required this.isOpaque,
  });
}

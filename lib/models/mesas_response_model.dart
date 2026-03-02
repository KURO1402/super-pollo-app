import 'mesas_model.dart';

class MesasResponseModel {
  final bool ok;
  final List<MesaModel> mesas;

  MesasResponseModel({required this.ok, required this.mesas});

  factory MesasResponseModel.fromJson(Map<String, dynamic> json) {
    return MesasResponseModel(
      ok: json['ok'],
      mesas: (json['mesas'] as List<dynamic>)
          .map((mesa) => MesaModel.fromJson(mesa))
          .toList(),
    );
  }
}

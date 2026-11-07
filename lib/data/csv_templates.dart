import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// En-têtes des modèles CSV (une colonne par champ importable).
///
/// Les fichiers `assets/templates/*.csv` doivent contenir exactement ces
/// en-têtes (vérifié par un test).
const String realEstateCsvHeader =
    'nom,valeur,devise,etablissement,note,statut,type_bail,locataire,'
    'loyer_hc,charges_locatives,depot_garantie,date_debut_bail,date_fin_bail,'
    'mode_gestion,frais_gestion,taxe_fonciere,assurance_pno,'
    'charges_copropriete,travaux_entretien,vacance_locative,note_location,'
    'a_un_credit,montant_credit,taux_credit_pct,mensualite_credit,'
    'duree_credit_mois,capital_restant_du,assurance_emprunteur';

const String startupCsvHeader =
    'nom,etablissement,note,type_titre,quantite,prix_entree,frais,'
    'date_investissement,stade,prix_actuel,date_valorisation,'
    'valorisation_entreprise,statut,date_sortie,produit_sortie,mode_sortie,'
    'levees,marche_secondaire';

const String realEstateTemplateName = 'modele_immobilier.csv';
const String startupTemplateName = 'modele_startups.csv';

/// Écrit les deux modèles dans `<documents>/templates/` et renvoie leur chemin.
Future<List<String>> writeCsvTemplates() async {
  final dir = await getApplicationDocumentsDirectory();
  final templates = Directory(p.join(dir.path, 'templates'));
  await templates.create(recursive: true);
  final paths = <String>[];
  for (final (name, header) in [
    (realEstateTemplateName, realEstateCsvHeader),
    (startupTemplateName, startupCsvHeader),
  ]) {
    final file = File(p.join(templates.path, name));
    await file.writeAsString('$header\n');
    paths.add(file.path);
  }
  return paths;
}

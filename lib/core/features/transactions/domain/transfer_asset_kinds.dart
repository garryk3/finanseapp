import 'package:finanseapp/core/features/assets/domain/asset.dart';

/// Виды активов, между которыми разрешён перевод (BR-T-10): счета и
/// инвестиции в любых сочетаниях; недвижимость — нет.
///
/// Единственный источник инварианта для DAO и формы перевода.
const Set<AssetKind> transferAssetKinds = {
  AssetKind.account,
  AssetKind.investment,
};

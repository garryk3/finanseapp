import 'package:finanseapp/app/app.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/home/ui/home_view_model.dart';
import 'package:flutter/widgets.dart';

void main() {
  final ServiceLocator locator = ServiceLocator()
    ..register<HomeViewModel>(HomeViewModel());
  runApp(FinanseApp(locator: locator));
}

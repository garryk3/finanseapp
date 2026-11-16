# Целевая структура файлов

Документ фиксирует структуру, которую нужно создавать постепенно задачами из `PLAN.md`.
На проектном этапе не создаются пустые каталоги или Dart-заглушки. Файл добавляется
только вместе с реализацией и тестом соответствующей задачи.

## 1. Корень и приложение

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── routes.dart
│   ├── shell_screen.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── app_semantic_colors.dart
│       ├── app_spacing.dart
│       ├── app_shapes.dart
│       └── chart_series_colors.dart
├── core/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── app_database.g.dart
│   │   ├── app_database_path.dart
│   │   ├── tables/
│   │   │   ├── assets.dart
│   │   │   ├── asset_details.dart
│   │   │   ├── asset_valuations.dart
│   │   │   ├── asset_transactions.dart
│   │   │   ├── asset_transaction_revisions.dart
│   │   │   ├── asset_transfers.dart
│   │   │   ├── cashflow_entries.dart
│   │   │   ├── cashflow_entry_revisions.dart
│   │   │   ├── subgroups.dart
│   │   │   ├── currencies.dart
│   │   │   ├── exchange_rates.dart
│   │   │   ├── categories.dart
│   │   │   ├── goals.dart
│   │   │   ├── goal_assets.dart
│   │   │   └── app_settings.dart
│   │   ├── daos/
│   │   │   ├── assets_dao.dart
│   │   │   ├── valuations_dao.dart
│   │   │   ├── transactions_dao.dart
│   │   │   ├── cashflow_dao.dart
│   │   │   ├── references_dao.dart
│   │   │   ├── currencies_dao.dart
│   │   │   ├── goals_dao.dart
│   │   │   ├── settings_dao.dart
│   │   │   └── audit_dao.dart
│   │   ├── converters/
│   │   │   ├── decimal_converter.dart
│   │   │   └── local_date_converter.dart
│   │   └── seed/seed_data.dart
│   ├── di/service_locator.dart
│   ├── domain/common/
│   │   ├── local_date.dart
│   │   ├── money.dart
│   │   ├── currency.dart
│   │   ├── exchange_rate.dart
│   │   ├── date_range.dart
│   │   ├── result.dart
│   │   ├── validation.dart
│   │   ├── money_math.dart
│   │   └── currency_converter.dart
│   ├── presentation/
│   │   ├── view_state.dart
│   │   ├── money_formatter.dart
│   │   └── date_formatter.dart
│   └── features/
│       ├── assets/
│       │   ├── domain/
│       │   │   ├── asset.dart
│       │   │   ├── asset_draft.dart
│       │   │   ├── asset_valuation.dart
│       │   │   ├── asset_repository.dart
│       │   │   ├── subgroup.dart
│       │   │   ├── subgroup_repository.dart
│       │   │   └── asset_value_calculator.dart
│       │   ├── data/
│       │   │   ├── asset_repository_impl.dart
│       │   │   └── asset_mappers.dart
│       │   ├── logic/
│       │   │   ├── save_asset.dart
│       │   │   ├── delete_or_archive_asset.dart
│       │   │   ├── record_asset_valuation.dart
│       │   │   └── account_forecast_calculator.dart
│       │   └── ui/
│       │       ├── assets_screen.dart
│       │       ├── assets_view_model.dart
│       │       ├── assets_state.dart
│       │       ├── account_form_screen.dart
│       │       ├── account_form_view_model.dart
│       │       ├── account_details_screen.dart
│       │       ├── account_details_view_model.dart
│       │       ├── investment_form_screen.dart
│       │       ├── investment_form_view_model.dart
│       │       ├── investment_details_screen.dart
│       │       ├── investment_details_view_model.dart
│       │       ├── property_form_screen.dart
│       │       ├── property_form_view_model.dart
│       │       ├── property_details_screen.dart
│       │       ├── property_details_view_model.dart
│       │       ├── valuation_form_screen.dart
│       │       ├── valuation_form_view_model.dart
│       │       └── widgets/
│       │           ├── asset_actions.dart
│       │           ├── account_forecast_section.dart
│       │           ├── valuation_history.dart
│       │           └── property_cashflow_section.dart
│       ├── transactions/
│       │   ├── domain/
│       │   │   ├── asset_transaction.dart
│       │   │   ├── asset_transaction_revision.dart
│       │   │   ├── transaction_filter.dart
│       │   │   └── asset_transaction_repository.dart
│       │   ├── data/
│       │   │   ├── asset_transaction_repository_impl.dart
│       │   │   └── asset_transaction_mappers.dart
│       │   ├── logic/
│       │   │   ├── save_asset_transaction.dart
│       │   │   ├── transfer_assets.dart
│       │   │   └── transaction_history_grouper.dart
│       │   └── ui/
│       │       ├── transactions_screen.dart
│       │       ├── transactions_view_model.dart
│       │       ├── transactions_state.dart
│       │       ├── transaction_form_screen.dart
│       │       ├── transaction_form_view_model.dart
│       │       ├── transfer_form_screen.dart
│       │       ├── transfer_form_view_model.dart
│       │       ├── transaction_details_screen.dart
│       │       ├── transaction_details_view_model.dart
│       │       └── widgets/
│       │           ├── transaction_filter_sheet.dart
│       │           └── transaction_list.dart
│       ├── cashflow/
│       │   ├── domain/
│       │   │   ├── cashflow_entry.dart
│       │   │   ├── cashflow_entry_revision.dart
│       │   │   ├── cashflow_filter.dart
│       │   │   ├── cashflow_summary.dart
│       │   │   ├── cashflow_calculator.dart
│       │   │   └── cashflow_repository.dart
│       │   ├── data/
│       │   │   ├── cashflow_repository_impl.dart
│       │   │   └── cashflow_mappers.dart
│       │   ├── logic/
│       │   │   ├── cashflow_commands.dart
│       │   │   └── calculate_cashflow.dart
│       │   └── ui/
│       │       ├── cashflow_screen.dart
│       │       ├── cashflow_view_model.dart
│       │       ├── cashflow_state.dart
│       │       ├── cashflow_form_screen.dart
│       │       ├── cashflow_form_view_model.dart
│       │       ├── cashflow_details_screen.dart
│       │       ├── cashflow_details_view_model.dart
│       │       └── widgets/
│       │           ├── cashflow_filter_sheet.dart
│       │           └── cashflow_list.dart
│       ├── categories/
│       │   ├── domain/
│       │   │   ├── cashflow_category.dart
│       │   │   └── category_repository.dart
│       │   ├── data/
│       │   │   ├── category_repository_impl.dart
│       │   │   └── category_mappers.dart
│       │   ├── logic/category_commands.dart
│       │   └── ui/
│       │       ├── categories_screen.dart
│       │       ├── categories_view_model.dart
│       │       ├── category_form_screen.dart
│       │       ├── category_form_view_model.dart
│       │       └── category_conflict_dialog.dart
│       ├── currencies/
│       │   ├── domain/
│       │   │   ├── currency_repository.dart
│       │   │   └── exchange_rate_repository.dart
│       │   ├── data/
│       │   │   ├── currency_repository_impl.dart
│       │   │   ├── exchange_rate_repository_impl.dart
│       │   │   ├── cbr_exchange_rate_client.dart
│       │   │   ├── cbr_xml_parser.dart
│       │   │   └── currency_mappers.dart
│       │   ├── logic/
│       │   │   ├── resolve_exchange_rate.dart
│       │   │   └── manage_base_currency.dart
│       │   └── ui/
│       │       ├── currencies_screen.dart
│       │       ├── currencies_view_model.dart
│       │       ├── currency_form_screen.dart
│       │       ├── currency_form_view_model.dart
│       │       ├── base_currency_screen.dart
│       │       ├── base_currency_view_model.dart
│       │       └── manual_rate_dialog.dart
│       ├── goals/
│       │   ├── domain/
│       │   │   ├── financial_goal.dart
│       │   │   ├── goal_progress.dart
│       │   │   ├── goal_calculator.dart
│       │   │   └── goal_repository.dart
│       │   ├── data/
│       │   │   ├── goal_repository_impl.dart
│       │   │   └── goal_mappers.dart
│       │   ├── logic/
│       │   │   ├── save_goal.dart
│       │   │   └── calculate_goal_progress.dart
│       │   └── ui/
│       │       ├── goals_screen.dart
│       │       ├── goals_view_model.dart
│       │       ├── goals_state.dart
│       │       ├── goal_form_screen.dart
│       │       ├── goal_form_view_model.dart
│       │       ├── goal_details_screen.dart
│       │       └── goal_details_view_model.dart
│       ├── analytics/
│       │   ├── domain/
│       │   │   ├── analytics_queries.dart
│       │   │   ├── net_worth_summary.dart
│       │   │   └── cashflow_period_point.dart
│       │   ├── data/
│       │   │   ├── analytics_queries_impl.dart
│       │   │   └── analytics_mappers.dart
│       │   ├── logic/
│       │   │   ├── build_net_worth_series.dart
│       │   │   └── cashflow_analytics.dart
│       │   └── ui/
│       │       ├── analytics_screen.dart
│       │       ├── analytics_view_model.dart
│       │       ├── analytics_state.dart
│       │       └── widgets/
│       │           ├── net_worth_chart_section.dart
│       │           └── cashflow_chart_section.dart
│       ├── dashboard/ui/
│       │   ├── dashboard_screen.dart
│       │   ├── dashboard_view_model.dart
│       │   ├── dashboard_state.dart
│       │   └── widgets/
│       │       ├── dashboard_net_worth.dart
│       │       ├── dashboard_goals.dart
│       │       ├── dashboard_recent_operations.dart
│       │       └── dashboard_cashflow.dart
│       ├── backup/
│       │   ├── domain/
│       │   │   ├── backup_service.dart
│       │   │   └── backup_exception.dart
│       │   ├── data/
│       │   │   ├── local_database_backup_service.dart
│       │   │   ├── backup_file_gateway.dart
│       │   │   └── platform_backup_file_gateway.dart
│       │   └── logic/backup_view_model.dart
│       ├── settings/
│       │   ├── data/
│       │   │   ├── settings_repository_impl.dart
│       │   │   └── github_update_service.dart
│       │   ├── domain/
│       │   │   ├── settings_repository.dart
│       │   │   ├── update_service.dart
│       │   │   └── app_version.dart
│       │   ├── logic/
│       │   │   ├── settings_commands.dart
│       │   │   └── update_check_view_model.dart
│       │   └── ui/
│       │       ├── more_screen.dart
│       │       ├── more_view_model.dart
│       │       ├── settings_screen.dart
│       │       ├── settings_view_model.dart
│       │       ├── about_screen.dart
│       │       ├── about_view_model.dart
│       │       └── widgets/
│       │           ├── backup_section.dart
│       │           └── update_section.dart
│       ├── references/
│       │   └── ui/
│       │       ├── subgroups_screen.dart
│       │       └── subgroups_view_model.dart
│       ├── app_info/ui/
│       │   ├── not_found_screen.dart
│       │   └── not_found_view_model.dart
│       └── audit/
│           ├── data/
│           │   ├── audit_repository_impl.dart
│           │   └── audit_mappers.dart
│           ├── domain/audit_repository.dart
│           └── ui/
│               ├── audit_screen.dart
│               ├── audit_view_model.dart
│               ├── audit_entry_details_screen.dart
│               ├── audit_entry_details_view_model.dart
│               └── revision_diff.dart
├── uikit/
│   ├── design/                       # готовые контракты, не implementation
│   ├── app_scaffold.dart
│   ├── app_top_app_bar.dart
│   ├── app_text.dart
│   ├── app_icon.dart
│   ├── app_box.dart
│   ├── app_card.dart
│   ├── app_section.dart
│   ├── app_ink_well.dart
│   ├── app_tap_region.dart
│   ├── app_image.dart
│   ├── app_list_tile.dart
│   ├── app_list_view.dart
│   ├── app_grid_view.dart
│   ├── app_button.dart
│   ├── app_icon_button.dart
│   ├── app_floating_action_button.dart
│   ├── app_navigation_bar.dart
│   ├── app_navigation_rail.dart
│   ├── app_dialog.dart
│   ├── app_bottom_sheet.dart
│   ├── app_snack_bar.dart
│   ├── app_spinner.dart
│   ├── app_skeleton.dart
│   ├── app_progress.dart
│   ├── app_divider.dart
│   ├── app_chip.dart
│   ├── app_tooltip.dart
│   ├── app_switch.dart
│   ├── app_checkbox.dart
│   ├── app_radio_list_tile.dart
│   ├── app_popup_menu.dart
│   ├── app_refresh_indicator.dart
│   ├── app_text_field.dart
│   ├── app_search_field.dart
│   ├── app_amount_field.dart
│   ├── app_date_picker_field.dart
│   ├── app_select.dart
│   ├── app_currency_select.dart
│   ├── app_category_select.dart
│   ├── app_asset_select.dart
│   ├── app_segmented_control.dart
│   ├── app_filter_chip.dart
│   ├── app_filter_bar.dart
│   ├── app_form_section.dart
│   ├── app_money_text.dart
│   ├── app_money_delta.dart
│   ├── app_exchange_rate_text.dart
│   ├── app_metric.dart
│   ├── app_summary_card.dart
│   ├── app_asset_list_tile.dart
│   ├── app_operation_list_tile.dart
│   ├── app_date_header.dart
│   ├── app_category_chip.dart
│   ├── app_goal_card.dart
│   ├── app_cashflow_summary.dart
│   ├── app_empty_state.dart
│   ├── app_error_state.dart
│   ├── app_confirm_dialog.dart
│   ├── app_chart_data.dart
│   ├── app_line_chart.dart
│   ├── app_cashflow_chart.dart
│   ├── app_chart_frame.dart
│   ├── app_chart_legend.dart
│   └── app_chart_tooltip.dart
└── l10n/
    ├── app_ru.arb
    └── app_localizations*.dart
```

`core/features/home/` удаляется задачей 3.5 вместе с демонстрационным счётчиком после
перевода `/` на Dashboard. До этого существующие smoke-тесты обновляются, не удаляются без
замены.

## 2. Тесты

```text
test/
├── app_test.dart
├── fixtures/
│   ├── cbr_daily.xml
│   └── cbr_daily_wrong_date.xml
└── core/
    ├── database/
    │   ├── app_database_test.dart
    │   ├── seed_data_test.dart
    │   └── revision_transaction_test.dart
    ├── domain/common/
    │   ├── local_date_test.dart
    │   ├── money_math_test.dart
    │   ├── currency_converter_test.dart
    │   └── golden_calculations_test.dart
    └── features/<feature>/
        ├── domain/*_test.dart
        ├── data/*_repository_test.dart
        ├── logic/*_test.dart
        └── ui/*_screen_test.dart

integration_test/
├── app_test.dart
├── helpers/test_app.dart
├── assets_flow_test.dart
├── transactions_flow_test.dart
├── cashflow_flow_test.dart
├── goals_flow_test.dart
├── analytics_flow_test.dart
├── backup_flow_test.dart
└── settings_flow_test.dart

drift_schemas/
└── drift_schema_v1.json
```

DB-тесты используют `AppDatabase(executor: NativeDatabase.memory())`; сеть заменяется
fake `CbrExchangeRateClient`, ViewModel-тесты — fake repositories из `mocktail` или
ручных fakes. Тесты не обращаются к реальному ЦБ РФ и не зависят от текущей даты: `today`
передаётся явно.

## 3. Правила размещения

- Один public component/entity/view model — один файл. Небольшие immutable state/data
  классы могут находиться рядом только если не используются другой фичей.
- Экран не содержит SQL, HTTP, формулы или маппинг Drift. Такой код переносится в
  `logic`, `domain` или `data` до ревью.
- Повторяющийся UI сначала остаётся feature widget; перенос в UIKit выполняется после
  второго реального использования и по контракту из `uikit/design/`.
- UIKit не принимает `Asset`, `CashflowEntry`, repository или `BuildContext`-dependent
  callback загрузки. Он получает String/num/Decimal presentation values и callbacks.
- Generated-код не редактируется вручную. Изменения схемы включают `.g.dart` и новый
  schema dump в одной задаче.
- Любой новый route добавляется в `routes.dart`, `router.dart`,
  `navigation_and_screens.md` и widget/integration тест в одной задаче.

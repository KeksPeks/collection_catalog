@echo off
title Collection Engine Architecture Creator

REM =====================================================
REM Function: create directory if missing
REM =====================================================

REM APP

if not exist lib\app mkdir lib\app

if not exist lib\app\app.dart type nul > lib\app\app.dart
if not exist lib\app\app_router.dart type nul > lib\app\app_router.dart
if not exist lib\app\app_theme.dart type nul > lib\app\app_theme.dart
if not exist lib\app\app_initializer.dart type nul > lib\app\app_initializer.dart


REM =====================================================
REM CORE
REM =====================================================

if not exist lib\core mkdir lib\core

if not exist lib\core\database mkdir lib\core\database
if not exist lib\core\database\tables mkdir lib\core\database\tables
if not exist lib\core\database\daos mkdir lib\core\database\daos
if not exist lib\core\database\migrations mkdir lib\core\database\migrations

if not exist lib\core\navigation mkdir lib\core\navigation
if not exist lib\core\services mkdir lib\core\services
if not exist lib\core\theme mkdir lib\core\theme
if not exist lib\core\utils mkdir lib\core\utils
if not exist lib\core\widgets mkdir lib\core\widgets


if not exist lib\core\database\app_database.dart type nul > lib\core\database\app_database.dart

if not exist lib\core\navigation\routes.dart type nul > lib\core\navigation\routes.dart
if not exist lib\core\navigation\navigation_service.dart type nul > lib\core\navigation\navigation_service.dart

if not exist lib\core\services\logger_service.dart type nul > lib\core\services\logger_service.dart
if not exist lib\core\services\file_service.dart type nul > lib\core\services\file_service.dart
if not exist lib\core\services\backup_service.dart type nul > lib\core\services\backup_service.dart

if not exist lib\core\theme\colors.dart type nul > lib\core\theme\colors.dart
if not exist lib\core\theme\typography.dart type nul > lib\core\theme\typography.dart
if not exist lib\core\theme\themes.dart type nul > lib\core\theme\themes.dart

if not exist lib\core\utils\validators.dart type nul > lib\core\utils\validators.dart
if not exist lib\core\utils\extensions.dart type nul > lib\core\utils\constants.dart

if not exist lib\core\widgets\app_button.dart type nul > lib\core\widgets\app_button.dart
if not exist lib\core\widgets\app_card.dart type nul > lib\core\widgets\app_card.dart
if not exist lib\core\widgets\empty_state.dart type nul > lib\core\widgets\empty_state.dart


REM =====================================================
REM FEATURES ROOT
REM =====================================================

if not exist lib\features mkdir lib\features


REM =====================================================
REM Collections
REM =====================================================

if not exist lib\features\collections mkdir lib\features\collections

mkdir lib\features\collections\data\models
mkdir lib\features\collections\data\repositories
mkdir lib\features\collections\data\datasources

mkdir lib\features\collections\domain\entities
mkdir lib\features\collections\domain\repositories
mkdir lib\features\collections\domain\services

mkdir lib\features\collections\presentation\pages
mkdir lib\features\collections\presentation\widgets

if not exist lib\features\collections\domain\entities\collection.dart type nul > lib\features\collections\domain\entities\collection.dart
if not exist lib\features\collections\presentation\pages\collections_page.dart type nul > lib\features\collections\presentation\pages\collections_page.dart
if not exist lib\features\collections\presentation\pages\collection_detail_page.dart type nul > lib\features\collections\presentation\pages\collection_detail_page.dart
if not exist lib\features\collections\presentation\widgets\collection_card.dart type nul > lib\features\collections\presentation\widgets\collection_card.dart


REM =====================================================
REM Templates
REM =====================================================

mkdir lib\features\templates\data
mkdir lib\features\templates\domain\entities
mkdir lib\features\templates\presentation

if not exist lib\features\templates\domain\entities\template.dart type nul > lib\features\templates\domain\entities\template.dart


REM =====================================================
REM Items
REM =====================================================

mkdir lib\features\items\data
mkdir lib\features\items\domain\entities
mkdir lib\features\items\domain\services
mkdir lib\features\items\presentation

if not exist lib\features\items\domain\entities\item.dart type nul > lib\features\items\domain\entities\item.dart
if not exist lib\features\items\domain\services\item_creator.dart type nul > lib\features\items\domain\services\item_creator.dart


REM =====================================================
REM Fields
REM =====================================================

mkdir lib\features\fields\domain\entities
mkdir lib\features\fields\domain\types
mkdir lib\features\fields\domain\components
mkdir lib\features\fields\presentation

if not exist lib\features\fields\domain\entities\field_definition.dart type nul > lib\features\fields\domain\entities\field_definition.dart
if not exist lib\features\fields\domain\entities\field_value.dart type nul > lib\features\fields\domain\entities\field_value.dart

if not exist lib\features\fields\domain\types\field_type.dart type nul > lib\features\fields\domain\types\field_type.dart

if not exist lib\features\fields\domain\components\text_component.dart type nul > lib\features\fields\domain\components\text_component.dart
if not exist lib\features\fields\domain\components\number_component.dart type nul > lib\features\fields\domain\components\number_component.dart
if not exist lib\features\fields\domain\components\dictionary_component.dart type nul > lib\features\fields\domain\components\dictionary_component.dart


REM =====================================================
REM Remaining feature modules
REM =====================================================

for %%F in (
dictionaries
storage
views
filters
attachments
search
downloads
sync
settings
) do (
    if not exist lib\features\%%F mkdir lib\features\%%F
)


REM Dictionaries

mkdir lib\features\dictionaries\domain\entities
mkdir lib\features\dictionaries\domain\services
mkdir lib\features\dictionaries\presentation

if not exist lib\features\dictionaries\domain\entities\dictionary.dart type nul > lib\features\dictionaries\domain\entities\dictionary.dart


REM Storage

mkdir lib\features\storage\domain\entities
mkdir lib\features\storage\domain\services
mkdir lib\features\storage\presentation

if not exist lib\features\storage\domain\entities\storage_node.dart type nul > lib\features\storage\domain\entities\storage_node.dart
if not exist lib\features\storage\domain\services\storage_tree_service.dart type nul > lib\features\storage\domain\services\storage_tree_service.dart


REM Views

mkdir lib\features\views\domain\entities
mkdir lib\features\views\domain\services
mkdir lib\features\views\presentation

if not exist lib\features\views\domain\entities\view_definition.dart type nul > lib\features\views\domain\entities\view_definition.dart
if not exist lib\features\views\domain\services\view_service.dart type nul > lib\features\views\domain\services\view_service.dart


REM Filters

mkdir lib\features\filters\domain\entities
mkdir lib\features\filters\domain\operators
mkdir lib\features\filters\presentation

if not exist lib\features\filters\domain\entities\filter.dart type nul > lib\features\filters\domain\entities\filter.dart


echo.
echo ========================================
echo Architecture created successfully
echo Existing files were preserved
echo ========================================

pause
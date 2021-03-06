import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:vocabulary_advancer/app/common/phrase_example_input.dart';
import 'package:vocabulary_advancer/app/phrase_editor_page_vm.dart';
import 'package:vocabulary_advancer/app/base/va_page.dart';
import 'package:vocabulary_advancer/app/services/dialogs.dart';
import 'package:vocabulary_advancer/app/themes/va_theme.dart';
import 'package:vocabulary_advancer/app/themes/card_decoration.dart';
import 'package:vocabulary_advancer/shared/root.dart';

class PhraseEditorPage extends VAPageWithArgument<PhraseEditorPageArgument, PhraseEditorPageVM> {
  PhraseEditorPage(PhraseEditorPageArgument argument) : super(argument);

  final _focusNodes = <FocusNode>[
    FocusNode(debugLabel: 'phraseGroupName'),
    FocusNode(debugLabel: 'phrase')..requestFocus(),
    FocusNode(debugLabel: 'pronunciation'),
    FocusNode(debugLabel: 'definition'),
    FocusNode(debugLabel: 'example')
  ];

  final _typeAheadController = TextEditingController();

  @override
  PhraseEditorPageVM createVM() => svc.vmPhraseEditorPage;

  @override
  AppBar buildAppBar(BuildContext context, PhraseEditorPageVM vm) => AppBar(
        title: Text(vm.isNewPhrase ? svc.i18n.titlesAddPhrase : svc.i18n.titlesEditPhrase,
            style: VATheme.of(context).textHeadline5),
        actions: [
          if (!vm.isNewPhrase)
            IconButton(
                icon: Icon(Icons.delete),
                color: VATheme.of(context).colorAttention,
                onPressed: () async {
                  final dialog = ConfirmDialog();
                  final confirmed = await dialog.showModal(
                      context: context,
                      title: svc.i18n.titlesConfirm,
                      messages: [svc.i18n.textConfirmationDeletePhrase],
                      confirmText: svc.i18n.labelsYes,
                      isDestructive: true);
                  if (confirmed) {
                    vm.deletePhraseAndClose();
                  }
                })
        ],
      );

  @override
  Widget buildBody(BuildContext context, PhraseEditorPageVM vm) => WillPopScope(
      onWillPop: () => _onWillPop(vm),
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          scrollDirection: Axis.vertical,
          child: Form(
              key: vm.formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    alignment: Alignment.topLeft,
                    decoration: cardDecoration(context),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                              label: Text(vm.phraseGroupName,
                                  style: VATheme.of(context).textBodyText2),
                              backgroundColor: VATheme.of(context).colorBackgroundMain),
                          TypeAheadFormField<String>(
                            textFieldConfiguration: TextFieldConfiguration(
                                focusNode: _focusNodes[0],
                                controller: _typeAheadController,
                                decoration:
                                    InputDecoration(labelText: svc.i18n.labelsEditorChangeGroup),
                                style: VATheme.of(context).textBodyText1,
                                onEditingComplete: () {
                                  _selectGroup(vm, _typeAheadController.text, andCleanInput: true);
                                }),
                            suggestionsCallback: (value) => vm.phraseGroupsKnownExceptSelected,
                            itemBuilder: (context, suggestion) => ListTile(
                              title: Text(suggestion),
                            ),
                            transitionBuilder: (context, suggestionsBox, controller) {
                              return suggestionsBox;
                            },
                            onSuggestionSelected: (suggestion) {
                              _selectGroup(vm, suggestion, andCleanInput: true);
                            },
                            onSaved: (value) {
                              _selectGroup(vm, value, andCleanInput: true);
                            },
                            hideOnEmpty: true,
                          )
                        ])),
                const SizedBox(height: 16.0),
                Container(
                    alignment: Alignment.topLeft,
                    decoration: cardDecoration(context),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                              decoration: InputDecoration(
                                  labelText: svc.i18n.labelsEditorPhrase,
                                  icon: Icon(Icons.mode_comment)),
                              initialValue: vm.phrase,
                              validator: (v) => vm.validatorForPhrase(
                                  v, svc.i18n.validationMessagesPhraseRequired),
                              onChanged: (v) => vm.updatePhrase(v),
                              focusNode: _focusNodes[1],
                              style: VATheme.of(context).textBodyText1),
                          const SizedBox(height: 16.0),
                          TextFormField(
                              decoration:
                                  InputDecoration(labelText: svc.i18n.labelsEditorPronunciation),
                              initialValue: vm.pronunciation,
                              onChanged: (v) => vm.updatePronunciation(v),
                              focusNode: _focusNodes[2],
                              style: VATheme.of(context).textBodyText1),
                          const SizedBox(height: 16.0),
                          TextFormField(
                              decoration:
                                  InputDecoration(labelText: svc.i18n.labelsEditorDefinition),
                              minLines: 3,
                              maxLines: 3,
                              initialValue: vm.definition,
                              validator: (v) => vm.validatorForDefinition(
                                  v, svc.i18n.validationMessagesDefinitionRequired),
                              onChanged: (v) => vm.updateDefinition(v),
                              focusNode: _focusNodes[3],
                              style: VATheme.of(context).textBodyText1),
                        ])),
                const SizedBox(height: 16.0),
                Container(
                    alignment: Alignment.topLeft,
                    decoration: cardDecoration(context),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhraseExampleTextFormField(
                              focusNode: _focusNodes[4],
                              onValidate: (v) => vm
                                  .validatorForExamples(svc.i18n.validationMessagesExampleRequired),
                              onSaved: vm.addExample),
                          SizedBox(
                              height: vm.examples.isNotEmpty ? 120 : 0,
                              child: ListView.builder(
                                  itemCount: vm.examples.length,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(8.0),
                                  itemBuilder: (context, i) =>
                                      Stack(alignment: Alignment.topRight, children: [
                                        Container(
                                          alignment: Alignment.topLeft,
                                          width: 240,
                                          padding: const EdgeInsets.only(
                                              top: 8.0, left: 8.0, right: 16.0, bottom: 16.0),
                                          margin: const EdgeInsets.only(top: 16.0, right: 16.0),
                                          decoration:
                                              cardDecoration(context, mainBackgroundColor: true),
                                          child: Wrap(children: [
                                            Text(vm.examples[i], overflow: TextOverflow.fade)
                                          ]),
                                        ),
                                        Transform.scale(
                                            scale: 0.8,
                                            child: CircleAvatar(
                                              backgroundColor: VATheme.of(context).colorAccent,
                                              child: IconButton(
                                                  icon: Icon(Icons.delete_outline),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    vm.removeExample(i);
                                                  }),
                                            ))
                                      ])))
                        ])),
              ]))));

  @override
  Widget buildFAB(BuildContext context, PhraseEditorPageVM vm) => FloatingActionButton(
      tooltip: svc.i18n.labelsSaveAndClose,
      onPressed: vm.tryApplyAndClose,
      child: Icon(Icons.save));

  void _selectGroup(PhraseEditorPageVM vm, String phraseGroupName, {bool andCleanInput}) {
    vm.updateGroupName(phraseGroupName);

    if (andCleanInput) {
      _typeAheadController.text = '';
      _focusNodes[0].unfocus();
    }
  }

  Future<bool> _onWillPop(PhraseEditorPageVM vm) async {
    for (final n in _focusNodes) {
      if (n.hasFocus) {
        n.unfocus();
        return false;
      }
    }

    return true;
  }
}

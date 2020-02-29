import 'package:flutter/material.dart';
import 'package:vocabulary_advancer/core/model.dart';
import 'package:vocabulary_advancer/core/view_model.dart';
import 'package:vocabulary_advancer/shared/root.dart';

class PhraseGroupGridPageVM extends BaseViewModel {
  PhraseGroup _phraseGroupSelected;
  List<PhraseGroup> phraseGroups = [];

  bool get anySelected => isReady && _phraseGroupSelected != null;
  bool get isNotEmpty => isReady && phraseGroups.isNotEmpty;

  @override
  Future Function(dynamic _) get initializer => (_) async {
        await Future.delayed(const Duration(milliseconds: 2000)); //TODO: remove
        phraseGroups = svc.repPhraseGroup.findMany().toList();
      };

  void select(PhraseGroup item) {
    notify(() => _phraseGroupSelected = item);
  }

  void unselect() {
    notify(() => _phraseGroupSelected = null);
  }

  bool isSelected(PhraseGroup item) => item == _phraseGroupSelected;

  Future navigateToAddGroup() => _navigateToEditor(isNew: true);
  Future navigateToEditGroup() => _navigateToEditor(isNew: false);
  Future _navigateToEditor({@required bool isNew}) async {
    assert(isNew || anySelected);
    final newPhraseGroup = isNew
        ? await svc.nav.forwardToAddPhraseGroup()
        : await svc.nav.forwardToEditPhraseGroup(_phraseGroupSelected.name);

    if (newPhraseGroup == null) return;

    notify(() {
      if (isNew) {
        phraseGroups.add(newPhraseGroup);
      } else {
        for (var i = 0; i < phraseGroups.length; i++) {
          if (phraseGroups[i] == _phraseGroupSelected) {
            phraseGroups[i] = newPhraseGroup;
          }
        }
        _phraseGroupSelected = newPhraseGroup;
      }
    });
  }

  Future navigateToGroup() {
    assert(anySelected);
    return svc.nav.forwardToPhraseGroup(_phraseGroupSelected.name);
  }

  Future navigateToAbout() {
    return svc.nav.forwardToAddPhraseGroup();
  }
}

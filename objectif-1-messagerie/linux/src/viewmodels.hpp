#ifndef VIEWMODELS_H
#define VIEWMODELS_H

#include <QAbstractListModel>
#include "models.h"

#include "TVM.hpp"

class NoteItem : public TItem<Note> {
    Q_OBJECT
    TM_QML_ITEM
};

class NoteViewModel : public TViewModel<Note> {
    Q_OBJECT
    TM_QML_VM(Note, NoteItem)
};

#endif // VIEWMODELS_H

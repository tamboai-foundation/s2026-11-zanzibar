#ifndef MODELS_H
#define MODELS_H

#include <QObject>

#include <model/TModel.hpp>

// Modèle d'exemple TModeler.
class Note : public TModel<Note> {
    TM_SCHEMA(Note, "ngoma.models", TF(title), TF(content))

    TextField title;
    TextField content;
};

// Incrémenter pour repartir d'une base vide.
constexpr int NGOMA_DB_VERSION = 1;

void initTModeler();

#endif // MODELS_H

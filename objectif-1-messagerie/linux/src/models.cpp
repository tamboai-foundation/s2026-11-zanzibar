#include "models.h"

#include <QDir>
#include <QStandardPaths>
#include <string>

TM_MANAGER(Note)

void initTModeler()
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/db";
    QDir().mkpath(dir);

    TModeler::start()
        .init(Tdb::Builder()
                  .type(Tdb::Type::SQLITE)
                  .dbDir(dir.toStdString())
                  .dbName("ngoma-" + std::to_string(NGOMA_DB_VERSION) + ".db")
                  .accept("ngoma.models")
                  .get());
}

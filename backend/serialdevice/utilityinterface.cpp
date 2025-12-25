#include "utilityinterface.h"

#include <QLoggingCategory>

#include "serialdevice/utility/restartoperation.h"
#include "serialdevice/utility/userbackupoperation.h"
#include "serialdevice/utility/userrestoreoperation.h"
#include "serialdevice/utility/startrecoveryoperation.h"
#include "serialdevice/utility/assetsdownloadoperation.h"
#include "serialdevice/utility/factoryresetutiloperation.h"
#include "serialdevice/utility/filesuploadoperation.h"
#include "serialdevice/utility/directorydownloadoperation.h"
#include "serialdevice/utility/pathcreateoperation.h"
#include "serialdevice/utility/startupdateroperation.h"
#include "serialdevice/utility/storageinforefreshoperation.h"
#include "serialdevice/utility/regionprovisioningoperation.h"
#include "serialdevice/utility/checksumverifyoperation.h"

Q_LOGGING_CATEGORY(LOG_UTILITY, "UTL")

using namespace Flipper;
using namespace Zero;

UtilityInterface::UtilityInterface(DeviceState *deviceState, ProtobufSession *rpc, QObject *parent):
    AbstractOperationRunner(parent),
    m_deviceState(deviceState),
    m_rpc(rpc)
{}

StartRecoveryOperation *UtilityInterface::startRecoveryMode()
{
    auto *operation = new StartRecoveryOperation(m_rpc, m_deviceState, this);
    enqueueOperation(operation);
    return operation;
}

AssetsDownloadOperation *UtilityInterface::downloadAssets(QIODevice *compressedFile)
{
    auto *operation = new AssetsDownloadOperation(m_rpc, m_deviceState, compressedFile, this);
    enqueueOperation(operation);
    return operation;
}

UserBackupOperation *UtilityInterface::backupInternalStorage(const QUrl &backupUrl)
{
    auto *operation = new UserBackupOperation(m_rpc, m_deviceState, backupUrl, this);
    enqueueOperation(operation);
    return operation;
}

UserRestoreOperation *UtilityInterface::restoreInternalStorage(const QUrl &backupUrl)
{
    auto *operation = new UserRestoreOperation(m_rpc, m_deviceState, backupUrl, this);
    enqueueOperation(operation);
    return operation;
}

RestartOperation *UtilityInterface::restartDevice()
{
    auto *operation = new RestartOperation(m_rpc, m_deviceState, this);
    enqueueOperation(operation);
    return operation;
}

FactoryResetUtilOperation *UtilityInterface::factoryReset()
{
    auto *operation = new FactoryResetUtilOperation(m_rpc, m_deviceState, this);
    enqueueOperation(operation);
    return operation;
}

FilesUploadOperation *UtilityInterface::uploadFiles(const QList<QUrl> &fileUrls, const QByteArray &remotePath)
{
    auto *operation = new FilesUploadOperation(m_rpc, m_deviceState, fileUrls, remotePath, this);
    enqueueOperation(operation);
    return operation;
}

DirectoryDownloadOperation *UtilityInterface::downloadDirectory(const QString &localDirectory, const QByteArray &remotePath)
{
    auto *operation = new DirectoryDownloadOperation(m_rpc, m_deviceState, localDirectory, remotePath, this);
    enqueueOperation(operation);
    return operation;
}

PathCreateOperation *UtilityInterface::createPath(const QByteArray &remotePath)
{
    auto *operation = new PathCreateOperation(m_rpc, m_deviceState, remotePath, this);
    enqueueOperation(operation);
    return operation;
}

StartUpdaterOperation *UtilityInterface::startUpdater(const QByteArray &manifestPath)
{
    auto *operation = new StartUpdaterOperation(m_rpc, m_deviceState, manifestPath, this);
    enqueueOperation(operation);
    return operation;
}

StorageInfoRefreshOperation *UtilityInterface::refreshStorageInfo()
{
    auto *operation = new StorageInfoRefreshOperation(m_rpc, m_deviceState, this);
    enqueueOperation(operation);
    return operation;
}

RegionProvisioningOperation *UtilityInterface::provisionRegionData()
{
    auto *operation = new RegionProvisioningOperation(m_rpc, m_deviceState, this);
    enqueueOperation(operation);
    return operation;
}

ChecksumVerifyOperation *UtilityInterface::verifyChecksum(const QList<QUrl> &urlsToCheck, const QByteArray &remoteRootPath)
{
    auto *operation = new ChecksumVerifyOperation(m_rpc, m_deviceState, urlsToCheck, remoteRootPath, this);
    enqueueOperation(operation);
    return operation;
}

const QLoggingCategory &UtilityInterface::loggingCategory() const
{
    return LOG_UTILITY();
}

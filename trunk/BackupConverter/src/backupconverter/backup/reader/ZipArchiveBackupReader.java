package backupconverter.backup.reader;


import backupconverter.backup.Collection;
import backupconverter.backup.Contents;
import backupconverter.backup.Item;
import backupconverter.backup.ItemPathComparator;
import backupconverter.backup.Resource;

import org.exist.backup.BackupDescriptor;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ZipArchiveBackupReader extends BackupReader
{
    private ZipFile zipFile = null;
    private Enumeration<? extends ZipEntry> zipFileEntries = null;

    public ZipArchiveBackupReader(File backupSrc)
    {
        super(backupSrc);
        
    }

    private ZipFile getZipFile() throws IOException
    {
        if(this.zipFile == null)
            this.zipFile = new ZipFile(backupSrc);

        return this.zipFile;
    }

    private Enumeration<? extends ZipEntry> getZipFileEntries() throws IOException
    {
        if(this.zipFileEntries == null)
            this.zipFileEntries = getZipFile().entries();

        return this.zipFileEntries;
    }

    @Override
    protected List<Item> getBackupItems() throws IOException
    {
        if(this.backupItems == null)
        {
            this.backupItems = new ArrayList<Item>();

            Enumeration<? extends ZipEntry> entries = getZipFileEntries();
            while(entries.hasMoreElements())
            {
                ZipEntry ze = entries.nextElement();
                String path = ze.getName();

                if(path.endsWith(BackupDescriptor.COLLECTION_DESCRIPTOR))
                {
                    String collectionPath = path.substring(0, path.lastIndexOf(BackupReader.PATH_SEPARATOR));
                    if(!isKnownCollection(collectionPath))
                    {
                        this.backupItems.add(new Collection(collectionPath));
                    }

                    this.backupItems.add(new Contents(path, zipFile.getInputStream(ze)));
                }
                else if(ze.isDirectory())
                {
                    String collectionPath = path;
                    if(collectionPath.endsWith(BackupReader.PATH_SEPARATOR))
                        collectionPath = collectionPath.substring(0, collectionPath.length()-1);

                    if(!isKnownCollection(collectionPath))
                    {
                        this.backupItems.add(new Collection(collectionPath));
                    }
                }
                else
                {
                    this.backupItems.add(new Resource(path, zipFile.getInputStream(ze)));
                }
            }

            Collections.sort(backupItems, new ItemPathComparator());
        }

        return this.backupItems;
    }

    @Override
    public void close() throws IOException
    {
        zipFile.close();
    }

    private boolean isKnownCollection(String collectionPath)
    {
        for(Item item : backupItems)
        {
            if(item instanceof Collection && item.getPath().equals(collectionPath))
                return true;
        }

        return false;
    }
}

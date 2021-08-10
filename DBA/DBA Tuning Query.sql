-- Tablespaces, ordered by percentage of space used
  SELECT a.TABLESPACE_NAME,
         a.BYTES / 1024 / 1024 Mbytes_used,
         b.BYTES / 1024 / 1024 Mbytes_free,
         ROUND ( ( (a.BYTES - b.BYTES) / a.BYTES) * 100, 2) percent_used
    FROM (  SELECT TABLESPACE_NAME, SUM (BYTES) BYTES
              FROM dba_data_files
          GROUP BY TABLESPACE_NAME) a
         LEFT OUTER JOIN
         (  SELECT TABLESPACE_NAME, SUM (BYTES) BYTES, MAX (BYTES) largest
              FROM dba_free_space
          GROUP BY TABLESPACE_NAME) b
            ON a.TABLESPACE_NAME = b.TABLESPACE_NAME
   WHERE 1 = 1 AND a.tablespace_name LIKE '%'
ORDER BY ( (a.BYTES - b.BYTES) / a.BYTES) DESC;

-- List files in a tablespace with current size and max size

SELECT file_name,
       bytes / 1024 / 1024 Mbytes,
       autoextensible,
       maxbytes / 1024 / 1024 M_maxbytes
  FROM dba_data_files
 WHERE tablespace_name = 'MASTER_TBS';


-- List files in a volume with current size and max size

  SELECT file_name,
         bytes / 1024 / 1024 Mbytes,
         autoextensible,
         maxbytes / 1024 / 1024 M_maxbytes
    FROM dba_data_files
   WHERE file_name LIKE '/u04/oradata7/%'
ORDER BY file_name;

-- Grow a datafile
--ALTER DATABASE DATAFILE '/u05/oradata/COGPREPO/perfstat_01.dbf' RESIZE 2048M;

-- add datafile
--ALTER TABLESPACE ALLHOTDB_DATA01 ADD DATAFILE '/ihotelt3/oradata/ihotelt3/allhotdb_data01_07.dbf' SIZE 10240M AUTOEXTEND OFF;

-- Free temp space

SELECT tablespace_name,
       total_blocks,
       used_blocks,
       free_blocks,
       total_blocks * 16 / 1024 AS total_MB,
       used_blocks * 16 / 1024 AS used_MB,
       free_blocks * 16 / 1024 AS free_MB
  FROM v$sort_segment;

--
-- So what's using the segments:
--

  SELECT b.TABLESPACE,
         b.segfile#,
         b.segblk#,
         b.blocks,
         b.blocks * 16 / 1024 AS MB,
         a.SID,
         a.serial#,
         a.status
    FROM v$session a, v$sort_usage b
   WHERE a.saddr = b.session_addr
ORDER BY b.TABLESPACE,
         b.segfile#,
         b.segblk#,
         b.blocks;
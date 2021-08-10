/* Formatted on 3/20/2020 10:34:09 AM (QP5 v5.287) */
SELECT b.tablespace_name, tbs_size SizeMb, a.free_space FreeMb
  FROM (  SELECT tablespace_name,
                 ROUND (SUM (bytes) / 1024 / 1024, 2) AS free_space
            FROM dba_free_space
        GROUP BY tablespace_name) a,
       (  SELECT tablespace_name, SUM (bytes) / 1024 / 1024 AS tbs_size
            FROM dba_data_files
        GROUP BY tablespace_name) b
 WHERE a.tablespace_name(+) = b.tablespace_name;


  SELECT df.tablespace_name tablespace_name,
         MAX (df.autoextensible) auto_ext,
         ROUND (df.maxbytes / (1024 * 1024), 2) max_ts_size,
         ROUND ( (df.bytes - SUM (fs.bytes)) / (df.maxbytes) * 100, 2)
            max_ts_pct_used,
         ROUND (df.bytes / (1024 * 1024), 2) curr_ts_size,
         ROUND ( (df.bytes - SUM (fs.bytes)) / (1024 * 1024), 2) used_ts_size,
         ROUND ( (df.bytes - SUM (fs.bytes)) * 100 / df.bytes, 2) ts_pct_used,
         ROUND (SUM (fs.bytes) / (1024 * 1024), 2) free_ts_size,
         NVL (ROUND (SUM (fs.bytes) * 100 / df.bytes), 2) ts_pct_free
    FROM dba_free_space fs,
         (  SELECT tablespace_name,
                   SUM (bytes) bytes,
                   SUM (DECODE (maxbytes, 0, bytes, maxbytes)) maxbytes,
                   MAX (autoextensible) autoextensible
              FROM dba_data_files
          GROUP BY tablespace_name) df
   WHERE fs.tablespace_name(+) = df.tablespace_name
GROUP BY df.tablespace_name, df.bytes, df.maxbytes
UNION ALL
  SELECT df.tablespace_name tablespace_name,
         MAX (df.autoextensible) auto_ext,
         ROUND (df.maxbytes / (1024 * 1024), 2) max_ts_size,
         ROUND ( (df.bytes - SUM (fs.bytes)) / (df.maxbytes) * 100, 2)
            max_ts_pct_used,
         ROUND (df.bytes / (1024 * 1024), 2) curr_ts_size,
         ROUND ( (df.bytes - SUM (fs.bytes)) / (1024 * 1024), 2) used_ts_size,
         ROUND ( (df.bytes - SUM (fs.bytes)) * 100 / df.bytes, 2) ts_pct_used,
         ROUND (SUM (fs.bytes) / (1024 * 1024), 2) free_ts_size,
         NVL (ROUND (SUM (fs.bytes) * 100 / df.bytes), 2) ts_pct_free
    FROM (  SELECT tablespace_name, bytes_used bytes
              FROM V$temp_space_header
          GROUP BY tablespace_name, bytes_free, bytes_used) fs,
         (  SELECT tablespace_name,
                   SUM (bytes) bytes,
                   SUM (DECODE (maxbytes, 0, bytes, maxbytes)) maxbytes,
                   MAX (autoextensible) autoextensible
              FROM dba_temp_files
          GROUP BY tablespace_name) df
   WHERE fs.tablespace_name(+) = df.tablespace_name
GROUP BY df.tablespace_name, df.bytes, df.maxbytes
ORDER BY 4 DESC;



SELECT df.tablespace_name "Tablespace",
       totalusedspace "Used MB",
       (df.totalspace - tu.totalusedspace) "Free MB",
       df.totalspace "Total MB",
       ROUND (100 * ( (df.totalspace - tu.totalusedspace) / df.totalspace))
          "Pct. Free"
  FROM (  SELECT tablespace_name, ROUND (SUM (bytes) / 1048576) TotalSpace
            FROM dba_data_files
        GROUP BY tablespace_name) df,
       (  SELECT ROUND (SUM (bytes) / (1024 * 1024)) totalusedspace,
                 tablespace_name
            FROM dba_segments
        GROUP BY tablespace_name) tu
 WHERE df.tablespace_name = tu.tablespace_name;
 SELECT    dtl.di::date                                                         AS "Day of install",
          dtl.dc                                                               AS "Activity Date",
          COALESCE (round(COALESCE(sum(cnt_conn), 0)/max(uc.users)*100, 2), 0) AS "% of active"
FROM      (
                 SELECT i::date              AS di,
                        extract(day FROM i2) AS dc
                 FROM   generate_series('2020-03-01', '2020-03-31', '1 day'::interval) i,
                        generate_series('2020-03-01', '2020-03-31', '1 day'::interval) i2) dtl
LEFT JOIN
          (
                    SELECT    u.installed::date                     AS installed,
                              extract(day FROM cs.created_at::date) AS created_at,
                              count(cs.userid)                      AS cnt_conn
                    FROM      USER u
                    LEFT JOIN client_session cs
                    ON        u.id=cs.userid
                    WHERE     (
                                        created_at BETWEEN '2020-03-01' AND       '2020-03-31'
                              OR        created_at IS NULL)
                    AND       u.installed BETWEEN '2020-03-01' AND       '2020-03-31'
                    GROUP BY  u.installed::  date,
                              cs.created_at::date) cnt
ON        dtl.di=cnt.installed
AND       dtl.dc=cnt.created_at
LEFT JOIN
          (
                   SELECT   installed::date AS installed,
                            count(*)        AS users
                   FROM     USER
                   GROUP BY installed::date) uc
ON        dtl.di=uc.installed
GROUP BY  dtl.di::date,
          dtl.dc
ORDER BY  dtl.di::date,
          dtl.dc; 

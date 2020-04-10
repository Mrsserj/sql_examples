SELECT 
  i.id, 
  i.name, 
  i.color,
  (array_agg(p.photo ORDER BY p.order_by) FILTER (where p.image_type = 'N'))[1] AS first_photo,
  Count(p.id) AS count_all_photo,
  Count(p.id) FILTER (where p.image_type = 'N') AS count_normal_photo
FROM startex_item i LEFT JOIN startex_itemphoto p ON i.id = p.item_id
GROUP BY 
  i.id, 
  i.name, 
  i.color
HAVING count(p.*)!=Count(p.id) FILTER (where p.image_type = 'N');

# Proyecto 3: Flujo SQL - Python - DRR
Tercer Proyecto - Bootcamp de Data Analytics

## 📌 Definición del Grano del Proyecto DF2
* **Definición:** Una fila representa una línea de pedido (order item) que contiene un producto específico, su categoría traducida, su precio, el coste de envío y el vendedor asociado.

### ¿Por qué elegimos este grano y lo dejamos aquí explicado?
* **Nivel de detalle:** Lo hemos definido así porque es la forma perfecta de ver el detalle exacto de cada venta (qué producto se vendió, cuánto costó, quién lo envió y su categoría), sin complicarnos con datos que no necesitamos y manteniendo la información muy limpia.
* **Justificación en el código:** Lo dejamos por escrito para que, si en el futuro tocamos estos datos para hacer gráficos o más código, sepamos exactamente qué es cada fila y evitemos mezclar cosas que puedan falsear los resultados o duplicar las ventas por error.

## 📊 Grano DF1 - Actividad del cliente
* Registro y seguimiento de la actividad detallada del cliente dentro del flujo del proyecto.
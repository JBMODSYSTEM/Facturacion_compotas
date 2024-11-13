require 'sqlite3'

DB = SQLite3::Database.new "compotas.db"

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS productos (
    id INTEGER PRIMARY KEY,
    tipo TEXT,
    cantidad INTEGER,
    descuento_porcentaje INTEGER,
    descuento REAL,
    venta_neta REAL
  );
SQL

def agregar_producto(tipo, cantidad, descuento_porcentaje, descuento, venta_neta)
  DB.execute("INSERT INTO productos (tipo, cantidad, descuento_porcentaje, descuento, venta_neta) VALUES (?, ?, ?, ?, ?)",
             [tipo, cantidad, descuento_porcentaje, descuento, venta_neta])
end

def obtener_productos
  DB.execute("SELECT * FROM productos")
end

def modificar_producto(id, cantidad, descuento_porcentaje, descuento, venta_neta)
  DB.execute("UPDATE productos SET cantidad = ?, descuento_porcentaje = ?, descuento = ?, venta_neta = ? WHERE id = ?",
             [cantidad, descuento_porcentaje, descuento, venta_neta, id])
end

def eliminar_producto(id)
  DB.execute("DELETE FROM productos WHERE id = ?", [id])
end

def limpiar_productos
  DB.execute("DELETE FROM productos")
end

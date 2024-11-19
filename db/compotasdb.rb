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

def agregar_producto(producto)
  DB.execute("INSERT INTO productos (tipo, cantidad, descuento_porcentaje, descuento, venta_neta) VALUES (?, ?, ?, ?, ?)",
             [producto.tipo, producto.cantidad, producto.descuento_porcentaje, producto.descuento, producto.venta_neta])
end

def obtener_productos
  DB.execute("SELECT * FROM productos").map do |row|
    tipo = row[1]
    case tipo
    when "Rostington"
      Rostington.new(row[0], row[2], row[3], row[4], row[5])
    when "Premiere"
      Premiere.new(row[0], row[2], row[3], row[4], row[5])
    end
  end
end

def modificar_producto(producto)
  DB.execute("UPDATE productos SET cantidad = ?, descuento_porcentaje = ?, descuento = ?, venta_neta = ? WHERE id = ?",
             [producto.cantidad, producto.descuento_porcentaje, producto.descuento, producto.venta_neta, producto.id])
end

def eliminar_producto(id)
  DB.execute("DELETE FROM productos WHERE id = ?", [id])
end

def limpiar_productos
  DB.execute("DELETE FROM productos")
end

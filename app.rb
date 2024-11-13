# app.rb
require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'db/compotasdb'

# Método para calcular el descuento y la venta neta
def calcular_descuento(tipo, cantidad)
  precio_unitario = tipo == "Rostington" ? 5000 : 10000
  descuento_porcentaje = case tipo
                         when "Rostington"
                           if cantidad <= 100
                             20
                           elsif cantidad <= 200
                             25
                           else
                             45
                           end
                         when "Premiere"
                           if cantidad <= 100
                             15
                           elsif cantidad <= 200
                             35
                           else
                             50
                           end
                         end
  venta_bruta = precio_unitario * cantidad
  descuento = venta_bruta * (descuento_porcentaje / 100.0)
  venta_neta = venta_bruta - descuento
  return venta_bruta, descuento, venta_neta, descuento_porcentaje
end

# Ruta principal para mostrar la interfaz de compra
get '/' do
  productos = obtener_productos.map do |row|
    {
      id: row[0],
      tipo: row[1],
      cantidad: row[2],
      descuento_porcentaje: row[3],
      descuento: row[4],
      venta_neta: row[5]
    }
  end
  total_general = productos.sum { |producto| producto[:venta_neta] }
  erb :index, locals: { productos: productos, total_general: total_general }
end

# Ruta para agregar un producto a la factura
post '/agregar_producto' do
  tipo = params[:tipo]
  cantidad = params[:cantidad].to_i

  if cantidad > 0
    venta_bruta, descuento, venta_neta, descuento_porcentaje = calcular_descuento(tipo, cantidad)
    agregar_producto(tipo, cantidad, descuento_porcentaje, descuento, venta_neta)
  end

  redirect '/'
end

# Ruta para modificar la cantidad de un producto
post '/modificar_cantidad' do
  id = params[:id].to_i
  nueva_cantidad = params[:cantidad].to_i

  if nueva_cantidad > 0
    producto = obtener_productos.find { |p| p[0] == id }
    tipo = producto[1]
    _, descuento, venta_neta, descuento_porcentaje = calcular_descuento(tipo, nueva_cantidad)
    modificar_producto(id, nueva_cantidad, descuento_porcentaje, descuento, venta_neta)
  end

  redirect '/'
end

# Ruta para eliminar un producto
post '/eliminar_producto' do
  id = params[:id].to_i
  eliminar_producto(id)
  redirect '/'
end

# Ruta para finalizar la compra
post '/finalizar_compra' do
  limpiar_productos
  redirect '/'
end

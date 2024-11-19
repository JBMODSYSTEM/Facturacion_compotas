# app.rb
require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'db/compotasdb'
require_relative 'models/producto'

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
  productos = obtener_productos
  total_general = productos.sum(&:venta_neta)
  erb :index, locals: { productos: productos, total_general: total_general }
end

# Ruta para agregar un producto a la factura
post '/agregar_producto' do
  tipo = params[:tipo]
  cantidad = params[:cantidad].to_i

  if cantidad > 0 && ["Rostington", "Premiere"].include?(tipo)
    productos = obtener_productos
    producto_existente = productos.find { |p| p.tipo == tipo }

    if producto_existente
      producto_existente.cantidad += cantidad
      modificar_producto(producto_existente)
    else
      producto = case tipo
                 when "Rostington"
                   Rostington.new(nil, cantidad)
                 when "Premiere"
                   Premiere.new(nil, cantidad)
                 end
      agregar_producto(producto)
    end
  else
    halt 400, "Datos inválidos"
  end

  redirect '/'
end

# Ruta para modificar la cantidad de un producto
post '/modificar_cantidad' do
  id = params[:id].to_i
  nueva_cantidad = params[:cantidad].to_i

  if nueva_cantidad > 0
    producto = obtener_productos.find { |p| p.id == id }
    producto.cantidad = nueva_cantidad
    modificar_producto(producto)
  else
    halt 400, "Cantidad inválida"
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

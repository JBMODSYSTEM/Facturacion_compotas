# app.rb
require 'sinatra'
require 'sinatra/reloader' if development?

# Variables globales para almacenar los datos de la compra actual
set :productos, []
set :total_general, 0

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
  erb :index, locals: { productos: settings.productos, total_general: settings.total_general }
end

# Ruta para agregar un producto a la factura
post '/agregar_producto' do
  tipo = params[:tipo]
  cantidad = params[:cantidad].to_i

  if cantidad > 0
    venta_bruta, descuento, venta_neta, descuento_porcentaje = calcular_descuento(tipo, cantidad)
    settings.total_general += venta_neta
    
    # Comprobar si el producto ya está en la lista
    existe = false
    settings.productos.each do |producto|
      if producto[:tipo] == tipo
        producto[:cantidad] += cantidad
        producto[:descuento] += descuento
        producto[:venta_neta] += venta_neta
        existe = true
        break
      end
    end

    # Si no existe, agregar nuevo
    unless existe
      settings.productos << {
        tipo: tipo,
        cantidad: cantidad,
        descuento_porcentaje: descuento_porcentaje,
        descuento: descuento,
        venta_neta: venta_neta
      }
    end
  end

  redirect '/'
end

# Ruta para modificar la cantidad de un producto
post '/modificar_cantidad' do
    index = params[:index].to_i
    nueva_cantidad = params[:cantidad].to_i
  
    if nueva_cantidad > 0
      producto = settings.productos[index]
      tipo = producto[:tipo]
      _, descuento, venta_neta, descuento_porcentaje = calcular_descuento(tipo, nueva_cantidad)
  
      # Actualizar los valores del producto
      settings.total_general -= producto[:venta_neta]
      producto[:cantidad] = nueva_cantidad
      producto[:descuento] = descuento
      producto[:venta_neta] = venta_neta
      producto[:descuento_porcentaje] = descuento_porcentaje
      settings.total_general += venta_neta
    end
  
    redirect '/'
  end
  
  # Ruta para eliminar un producto
  post '/eliminar_producto' do
    index = params[:index].to_i
  
    # Resta el valor de venta neta del producto al total general
    settings.total_general -= settings.productos[index][:venta_neta]
    settings.productos.delete_at(index)
  
    redirect '/'
  end
  

# Ruta para finalizar la compra
post '/finalizar_compra' do
  settings.productos = []
  settings.total_general = 0
  redirect '/'
end

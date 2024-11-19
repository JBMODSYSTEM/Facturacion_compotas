
class Producto
  attr_accessor :id, :tipo, :cantidad, :descuento_porcentaje, :descuento, :venta_neta

  def initialize(id, cantidad, descuento_porcentaje = 0, descuento = 0, venta_neta = 0)
    @id = id
    @cantidad = cantidad
    @descuento_porcentaje = descuento_porcentaje
    @descuento = descuento
    @venta_neta = venta_neta
    calcular_descuento
  end

  def calcular_descuento
    raise NotImplementedError, 'Este método debe ser implementado por las subclases'
  end
end

class Rostington < Producto
  def initialize(id, cantidad, descuento_porcentaje = 0, descuento = 0, venta_neta = 0)
    @tipo = "Rostington"
    super
  end

  def calcular_descuento
    precio_unitario = 5000
    @descuento_porcentaje = if @cantidad <= 100
                              20
                            elsif @cantidad <= 200
                              25
                            else
                              45
                            end
    venta_bruta = precio_unitario * @cantidad
    @descuento = venta_bruta * (@descuento_porcentaje / 100.0)
    @venta_neta = venta_bruta - @descuento
  end
end

class Premiere < Producto
  def initialize(id, cantidad, descuento_porcentaje = 0, descuento = 0, venta_neta = 0)
    @tipo = "Premiere"
    super
  end

  def calcular_descuento
    precio_unitario = 10000
    @descuento_porcentaje = if @cantidad <= 100
                              15
                            elsif @cantidad <= 200
                              35
                            else
                              50
                            end
    venta_bruta = precio_unitario * @cantidad
    @descuento = venta_bruta * (@descuento_porcentaje / 100.0)
    @venta_neta = venta_bruta - @descuento
  end
end
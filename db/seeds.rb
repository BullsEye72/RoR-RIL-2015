# Admin default
Admin.create!(
  email:                  'admin@admin.com',
  password:               'admin888',
  password_confirmation:  'admin888'
)

# User default
User.create!(
  email:                  'user@madera.com',
  password:               'user8888',
  password_confirmation:  'user8888',
  lastname:               'Utilisateur par défaut'
)

# Commercial
commercial = User.new(
    email:                  'commercial@madera.com',
    password:               'commercial',
    password_confirmation:  'commercial',
    lastname:               'Service Commercial'
)
commercial.add_role :commercial
commercial.save!

# Achats
purchaser = User.new(
    email:                  'achat@madera.com',
    password:               'achat888',
    password_confirmation:  'achat888',
    lastname:               'Service Achats'
)
purchaser.add_role :purchaser
purchaser.save!

# BE
conceptor = User.new(
    email:                  'betudes@madera.com',
    password:               'betudes88',
    password_confirmation:  'betudes88',
    lastname:               "Bureau d'études"
)
conceptor.add_role :conceptor
conceptor.save!

# PaymentStates
[
  'A facturer',
  'Facturé',
  'Payé'
].each {|ps| PaymentState.create!(name:  ps) }

# ConstructionStates
[
    { name: 'Devis signé', value: 0.03},
    { name: 'Permis de construire obtenu', value: 0.1},
    { name: 'Chantier ouvert', value: 0.15},
    { name: 'Fondations achevées', value: 0.25},
    { name: 'Mur achevé', value: 0.4},
    { name: "Mis hors d'eau/ hors d'air", value: 0.75},
    { name: 'Travaux achevés', value: 0.95},
    { name: 'Clef remises', value: 1},
].each {|cs| ConstructionState.create! cs }

# VAT
[
  { name: 'Taux normal', value: 20.0},
  { name: 'Taux réduit', value: 5.5}
].each {|cs| ValueAddedTax.create! cs }

# Article_Groups
[
  { name: 'Montants', description: 'Montants en bois pour la structure, nommés lisses ou contrefort' , article_group_id: nil},
  { name: 'Montage', description: 'Eléments de montages, sabots métalliques, boulons, gougeons' , article_group_id: nil},
  { name: 'Panneaux 1', description: 'Panneaux d’isolation et pare-pluie ' , article_group_id: nil},
  { name: 'Panneaux 2', description: "Panneaux intermédiaires et de couverture (intérieur ou extérieur)" , article_group_id: nil},
  { name: 'Plancher', description: '' , article_group_id: nil},
  { name: 'Couverture', description: '' , article_group_id: nil}
].each {|cs| ArticleGroup.create! cs }

# QuoteStates
%w(
 brouillon
  accepté
  en\ attente
  refusé
  en\ commande
  transfert\ en\ facturation
).each { |qs| QuoteState.create! name: qs}

# Catégories d'unités
[
  { name: 'Longueur ' },
  { name: 'Quantité' },
  { name: 'Surface' },
  { name: 'Poids' },
  { name: 'Volume' },
  { name: 'Autre' }
].each {|u| UnitCategory.create! u }

# Unités
[
  { name: 'U',   regex: '(?<= )[uU]',       unit_category_id: 2 },
  { name: 'm²',  regex: '(?<= )([mM][²2])', unit_category_id: 3 },
  { name: 'm³',  regex: '(?<= )([mM][³3])', unit_category_id: 5 },
  { name: 'm',   regex: '(?<= )[mM]',       unit_category_id: 1 },
  { name: 'mm',  regex: '(?<= )([mM]{2})',  unit_category_id: 1 },
  { name: 'L',   regex: '(?<= )[lL]',       unit_category_id: 5 },
  { name: 'T',   regex: '(?<= )[tT]',       unit_category_id: 4 },
  { name: 'g',   regex: '(?<= )[gG]',       unit_category_id: 4 },
  { name: 'kg',  regex: '(?<= )([kK][gG])', unit_category_id: 4 }
].each {|u| Unit.create! u }

# =================== DONNEES FICTIVES POUR TESTER L'AFFICHAGE ==========================

# Customers & Projects
10.times do
  # Customers
  Customer.create!(
      firstname:    Faker::Name.first_name,
      lastname:     Faker::Name.last_name,
      address:      "#{Faker::Address.street_address},
                     #{Faker::Address.postcode} #{Faker::Address.city}",
      phone_number: "0#{Faker::Number.number(9)}"
  )
  
  # Projects
  Project.create!(
      description:    'Projet test',
      customer:     Customer.last
  )
end

# Suppliers & Articles
30.times do
  # Suppliers
  Supplier.create!(
      name:    Faker::Company.suffix + " " + Faker::Company.name,
      phone_number:     "0#{Faker::Number.number(9)}",
      siret:      Faker::Company.swedish_organisation_number,
      fax_number: "0#{Faker::Number.number(9)}"
  )
  
  # Articles
  rand(10..20).times do
    Article.create!(
      name: Faker::Commerce.product_name,
      value_added_tax_id: 1,
      reference: Faker::Code.asin,
      description: Faker::Lorem.paragraph(3),
      article_group: ArticleGroup.order('RANDOM()').first
    )
    
    a=ArticlesUnit.new(
      article_id: Article.last.id,
      unit_id: Unit.order('RANDOM()').first.id,
      value: rand(1000)
      )
    a.save if a.validate
    
    ArticlesSupplier.create!(
      supplier_id: Supplier.last.id,
      article_id: Article.last.id,
      supplier_reference: Faker::Lorem.characters(rand(5..10)).upcase,
      price: rand(0.5..3000.0).round(2)
    )
  end
end

#Ajout de liasons
Supplier.all.each do |supplier|
  rand(5..10).times do
    a=ArticlesSupplier.new(
      supplier_id: supplier.id,
      article_id: rand(Article.all.count),
      supplier_reference: Faker::Lorem.characters(rand(5..10)).upcase,
      price: rand(0.5..3000.0).round(2)
    )
  
    a.save if a.validate
  end
end

#Quelques devis bidons
10.times do
  a=Quote.new(
      project: Project.order("RANDOM()").first,
      user: User.order("RANDOM()").first
  )

  loop_cnt=0
  while !a.validate
    loop_cnt+=1
    break if loop_cnt>10
    
    a=Quote.new(project: Project.order("RANDOM()").first, user: User.order("RANDOM()").first)
  end
  a.save if a.validate
end

# Commandes bidons
20.times do
  Order.create!(supplier: Supplier.order("RANDOM()").first, quote: Quote.order("RANDOM()").first)

#   Items bidons
  rand(5..30).times do
    OrderItem.create!(articles_supplier: ArticlesSupplier.order("RANDOM()").first,
                      order: Order.last,
                      quantity: rand(1..10))
  end

end



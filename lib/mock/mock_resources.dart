import '../models/resource.dart';

class MockResources {
  static List<Resource> getInitialResources() {
    final now = DateTime.now();

    return [
      // Equipment
      Resource(
        id: 'res_eq_01',
        title: 'VST Shakti 13HP Power Tiller',
        category: ResourceCategory.equipment,
        providerName: 'Rameshwar Jadhav',
        providerPhone: '+91 94044 55667',
        location: 'Riverbank Sector',
        distanceKm: 2.1,
        availabilityText: 'Available Today',
        priceText: '₹750 / day',
        description:
            'Reliable diesel power tiller with rotary tines and furrower attachment. Perfect for deep tilling, bed preparation, and weeding between wide rows.',
        iconEmoji: '🚜',
        specifications: {
          'Power': '13 HP Diesel',
          'Fuel Capacity': '11 Liters',
          'Tilling Width': '600 mm',
          'Condition': 'Recently Serviced',
        },
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Resource(
        id: 'res_eq_02',
        title: 'Mahindra 45HP Tractor with 4-Bottom Plough',
        category: ResourceCategory.equipment,
        providerName: 'Anil Kumar',
        providerPhone: '+91 99700 11223',
        location: 'Sunrise Orchards',
        distanceKm: 3.5,
        availabilityText: 'Available Tomorrow',
        priceText: '₹1,400 / hour (with driver)',
        description:
            'Heavy duty 4WD tractor suitable for deep tillage, levelling, and heavy trailer transport. Comes with experienced operator.',
        iconEmoji: '🚜',
        specifications: {
          'Engine': '45 HP, 4 Cylinders',
          'Hydraulics': '1500 kg capacity',
          'Implement': '4-Bottom Reversible Plough',
          'Includes': 'Driver + Fuel',
        },
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Resource(
        id: 'res_eq_03',
        title: '16L Dual Battery Knapsack Sprayer',
        category: ResourceCategory.equipment,
        providerName: 'Rajesh Shinde',
        providerPhone: '+91 98221 44556',
        location: 'Nashik Valley',
        distanceKm: 1.4,
        availabilityText: 'Available Today',
        priceText: '₹200 / day',
        description:
            'Rechargeable 12V 12Ah lithium battery powered sprayer with brass lance and 4 interchangeable misting nozzles. Delivers consistent fine spray.',
        iconEmoji: '🧰',
        specifications: {
          'Tank': '16 Liters',
          'Battery': '12V 12Ah Lithium',
          'Working Pressure': '0.2 - 0.45 Mpa',
          'Continuous Run': '6 to 8 hours',
        },
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Resource(
        id: 'res_eq_04',
        title: 'Multi-Crop High-Speed Thresher',
        category: ResourceCategory.equipment,
        providerName: 'Suresh Patil',
        providerPhone: '+91 94230 77889',
        location: 'Green Valley',
        distanceKm: 4.0,
        availabilityText: 'Available this Weekend',
        priceText: '₹900 / acre',
        description:
            'PTO operated multi-crop thresher capable of processing wheat, soybean, chickpeas, and mustard with minimal grain breakage.',
        iconEmoji: '⚙️',
        specifications: {
          'Drive': 'Tractor PTO operated',
          'Crops': 'Wheat, Pulses, Mustard',
          'Output Capacity': '1.2 - 1.8 Tons/hr',
          'Blower': 'Double cleaning blower',
        },
        createdAt: now.subtract(const Duration(days: 5)),
      ),

      // Irrigation
      Resource(
        id: 'res_irr_01',
        title: '5HP Solar DC Submersible Borewell Pump',
        category: ResourceCategory.irrigation,
        providerName: 'Meena Rathod',
        providerPhone: '+91 91588 66778',
        location: 'AgroTech Hub',
        distanceKm: 1.8,
        availabilityText: 'In Stock / Ready',
        priceText: '₹3,500 / month shared rental',
        description:
            'High-efficiency stainless steel solar pump connected to 4.8 kW panel array. Delivers 25,000 L/hr discharge up to 70m head.',
        iconEmoji: '💧',
        specifications: {
          'Rating': '5 HP DC Brushless',
          'Max Head': '90 Meters',
          'Discharge': '28,000 L/hr',
          'Solar Panels': '12 x 400W Mono Perc',
        },
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Resource(
        id: 'res_irr_02',
        title: 'Drip Lateral Rolls (16mm Inline, 40cm Spacing)',
        category: ResourceCategory.irrigation,
        providerName: 'Rajesh Shinde',
        providerPhone: '+91 98221 44556',
        location: 'Nashik Valley',
        distanceKm: 1.4,
        availabilityText: '3 Rolls Available',
        priceText: '₹1,850 / 400m bundle',
        description:
            'Virgin grade UV-stabilized inline drip tubing with pressure-compensating 2 LPH emitters. Surplus from recent greenhouse expansion.',
        iconEmoji: '🚰',
        specifications: {
          'Diameter': '16 mm Class 2',
          'Emitter Spacing': '40 cm',
          'Discharge Rate': '2.0 Liters/hr',
          'Roll Length': '400 meters',
        },
        createdAt: now.subtract(const Duration(days: 6)),
      ),

      // Seeds & Saplings
      Resource(
        id: 'res_sd_01',
        title: 'Bhagwa Pomegranate Certified Grafted Saplings',
        category: ResourceCategory.seedsSaplings,
        providerName: 'Anil Kumar',
        providerPhone: '+91 99700 11223',
        location: 'Sunrise Orchards',
        distanceKm: 3.5,
        availabilityText: '250 Plants Ready',
        priceText: '₹65 / sapling',
        description:
            'Tissue cultured & air-layered disease-free Bhagwa pomegranate saplings. High red aril sweetness and early fruiting potential.',
        iconEmoji: '🌱',
        specifications: {
          'Variety': 'Super Bhagwa (Ruby Red)',
          'Age': '9 Months Old',
          'Rootstock': 'Wilt resistant certified',
          'Packaging': 'Biodegradable polybags',
        },
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Resource(
        id: 'res_sd_02',
        title: 'F1 Hybrid Bell Pepper / Capsicum Saplings',
        category: ResourceCategory.seedsSaplings,
        providerName: 'Meena Rathod',
        providerPhone: '+91 91588 66778',
        location: 'AgroTech Hub',
        distanceKm: 1.8,
        availabilityText: '800 Seedlings in Trays',
        priceText: '₹4.50 / sapling',
        description:
            'Hardened 28-day-old Indra variety capsicum seedlings raised in coco-peat plug trays inside pest-free nursery tunnels.',
        iconEmoji: '🫑',
        specifications: {
          'Variety': 'Indra F1 Hybrid',
          'Tray Size': '104-cavity pro-trays',
          'Maturity': 'Ready for field transplantation',
          'Foliage': 'Vigorous 4-5 true leaf stage',
        },
        createdAt: now.subtract(const Duration(days: 1)),
      ),

      // Tools & Supplies
      Resource(
        id: 'res_tl_01',
        title: 'Heavy Duty Ergonomic Pruning Shears & Loppers',
        category: ResourceCategory.toolsSupplies,
        providerName: 'Anil Kumar',
        providerPhone: '+91 99700 11223',
        location: 'Sunrise Orchards',
        distanceKm: 3.5,
        availabilityText: 'Available Today',
        priceText: '₹120 / day',
        description:
            'SK5 high carbon steel bypass secateurs and telescopic tree loppers with cushioned handles. Sharpened and oiled.',
        iconEmoji: '✂️',
        specifications: {
          'Blade': 'Teflon coated Japanese SK5 steel',
          'Cutting Cap': 'Up to 35mm branch diameter',
          'Grip': 'Shock-absorbing anti-slip rubber',
        },
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // Farming Inputs
      Resource(
        id: 'res_in_01',
        title: 'Enriched Vermicompost (Cow Dung + Neem Enriched)',
        category: ResourceCategory.farmingInputs,
        providerName: 'Suresh Patil',
        providerPhone: '+91 94230 77889',
        location: 'Green Valley',
        distanceKm: 4.0,
        availabilityText: '30 Bags in Stock',
        priceText: '₹380 / 50kg bag',
        description:
            'Organic worm castings produced from desi cow manure using Eisenia fetida worms. Fortified with 5% neem cake to suppress soil nematodes.',
        iconEmoji: '🧪',
        specifications: {
          'Organic Carbon': '> 18%',
          'NPK Balance': '1.8 : 1.2 : 1.4',
          'Moisture': '20 - 25%',
          'Weight': '50 kg HDPE bags',
        },
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Resource(
        id: 'res_in_02',
        title: 'Pure Cold-Pressed Neem Oil (10,000 PPM Azadirachtin)',
        category: ResourceCategory.farmingInputs,
        providerName: 'Sunita Deshmukh',
        providerPhone: '+91 98811 33445',
        location: 'East Meadows',
        distanceKm: 4.2,
        availabilityText: 'Available',
        priceText: '₹650 / 5L can',
        description:
            '100% natural cold pressed neem seed kernel oil with emulsifier already added. Dilutes easily in water for natural pest deterrence.',
        iconEmoji: '🌿',
        specifications: {
          'Purity': '100% Cold pressed',
          'Azadirachtin': '10,000 PPM',
          'Dosage': '3 to 5 ml per liter',
        },
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}

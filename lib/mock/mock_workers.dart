import '../models/worker.dart';

class MockWorkers {
  static List<FarmWorker> getInitialWorkers() {
    return [
      const FarmWorker(
        id: 'wrk_01',
        name: 'Suresh Gaikwad',
        role: 'Harvesting & Pruning Specialist',
        skills: ['Fruit Harvesting', 'Tree Pruning', 'Vegetable Picking', 'Sorting & Grading'],
        experienceYears: 8,
        location: 'Nashik Valley',
        distanceKm: 2.5,
        availability: 'Available Tomorrow',
        dailyRate: '₹600 / day',
        rating: 4.9,
        phone: '+91 97654 32101',
        about:
            'Reliable and hardworking farm specialist with 8 years of experience in delicate fruit plucking, manual tomato staking, and crop pruning.',
        avatarEmoji: '👷',
      ),
      const FarmWorker(
        id: 'wrk_02',
        name: 'Ramesh More',
        role: 'Irrigation & Spray Technician',
        skills: ['Drip Maintenance', 'Battery Spraying', 'Filter Cleaning', 'Pump Operation'],
        experienceYears: 6,
        location: 'Riverbank Sector',
        distanceKm: 3.2,
        availability: 'Available Today',
        dailyRate: '₹650 / day',
        rating: 4.8,
        phone: '+91 97654 32102',
        about:
            'Experienced in managing drip irrigation networks, flush valve operations, backwashing filters, and uniform foliar spraying.',
        avatarEmoji: '🧑‍🌾',
      ),
      const FarmWorker(
        id: 'wrk_03',
        name: 'Kamalabai Shinde',
        role: 'Transplanting & Weeding Expert',
        skills: ['Nursery Transplanting', 'Manual Weeding', 'Mulch Laying', 'Seedling Planting'],
        experienceYears: 12,
        location: 'Green Valley',
        distanceKm: 4.1,
        availability: 'Available from Thursday',
        dailyRate: '₹500 / day',
        rating: 4.9,
        phone: '+91 97654 32103',
        about:
            'Leads a seasoned team of 4 workers adept at rapid seedling transplanting in raised beds without root shock.',
        avatarEmoji: '👩‍🌾',
      ),
      const FarmWorker(
        id: 'wrk_04',
        name: 'Baburao Chavan',
        role: 'Tractor Driver & Land Preparer',
        skills: ['Ploughing', 'Rotavator Operation', 'Ridge Making', 'Trailer Haulage'],
        experienceYears: 15,
        location: 'Sunrise Orchards',
        distanceKm: 5.4,
        availability: 'Available Today',
        dailyRate: '₹800 / day',
        rating: 4.7,
        phone: '+91 97654 32104',
        about:
            'Licensed commercial tractor driver skilled in precise furrowing, bed making, and safely maneuvering in sloping terrain.',
        avatarEmoji: '🚜',
      ),
    ];
  }
}
